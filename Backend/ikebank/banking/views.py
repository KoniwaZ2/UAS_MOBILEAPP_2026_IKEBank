import secrets

from django.db.models import DecimalField, Q, Sum, Value
from django.db.models.functions import Coalesce
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import BankAccount, CashFlow, Transaction
from .serializers import CashFlowCalculateSerializer, CashFlowSerializer, RegisterBankAccountSerializer


class RegisterBankAccountView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @staticmethod
    def _generate_unique_account_number(length=12, max_attempts=20):
        lower = 10 ** (length - 1)
        upper = (10 ** length) - 1

        for _ in range(max_attempts):
            account_number = str(secrets.randbelow(upper - lower + 1) + lower)
            if not BankAccount.objects.filter(account_number=account_number).exists():
                return account_number

        raise RuntimeError('Unable to generate unique account number at this time.')

    def post(self, request):
        serializer = RegisterBankAccountSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        account_number = self._generate_unique_account_number()
        card_number = f"4000{account_number[-12:]}"  # Contoh format kartu

        bank_account = BankAccount.objects.create(
            user=request.user,
            account_number=account_number,
            card_number=card_number,
            balance=0.00,
        )

        return Response({
            'id': bank_account.id,
            'account_number': bank_account.account_number,
            'card_number': bank_account.card_number,
            'balance': str(bank_account.balance),
            'created_at': bank_account.created_at,
            'updated_at': bank_account.updated_at,
        }, status=status.HTTP_201_CREATED)  

class CashFlowCalculateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @staticmethod
    def _calculate_status(total_income, total_expense):
        if total_income <= 0:
            return 'belum_optimal'

        saving_rate = (total_income - total_expense) / total_income
        if saving_rate >= 0.5:
            return 'sangat_optimal'
        if saving_rate >= 0.2:
            return 'optimal'
        if saving_rate >= 0:
            return 'cukup_optimal'
        return 'belum_optimal'

    def post(self, request):
        input_serializer = CashFlowCalculateSerializer(data=request.data)
        input_serializer.is_valid(raise_exception=True)
        validated_data = input_serializer.validated_data

        account = BankAccount.objects.filter(
            id=validated_data['account_id'],
            user=request.user,
        ).first()

        if account is None:
            return Response(
                {'detail': 'Bank account not found or not owned by user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        month = validated_data['month']
        year = validated_data['year']

        aggregates = Transaction.objects.filter(
            account_id=account,
            timestamp__year=year,
            timestamp__month=month,
        ).aggregate(
            total_income=Coalesce(
                Sum('amount', filter=Q(category_id__direction='income')),
                Value(0),
                output_field=DecimalField(max_digits=12, decimal_places=2),
            ),
            total_expense=Coalesce(
                Sum('amount', filter=Q(category_id__direction='expense')),
                Value(0),
                output_field=DecimalField(max_digits=12, decimal_places=2),
            ),
        )

        total_income = aggregates['total_income']
        total_expense = aggregates['total_expense']
        status_value = self._calculate_status(total_income, total_expense)

        cashflow, _ = CashFlow.objects.update_or_create(
            account_id=account,
            month=month,
            year=year,
            defaults={
                'total_income': total_income,
                'total_expense': total_expense,
                'status': status_value,
            },
        )

        output_serializer = CashFlowSerializer(cashflow)
        return Response(output_serializer.data, status=status.HTTP_200_OK)
