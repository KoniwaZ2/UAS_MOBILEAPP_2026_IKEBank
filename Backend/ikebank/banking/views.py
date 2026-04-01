import secrets

from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import BankAccount, Saku
from .serializers import CashFlowCalculateSerializer, CashFlowSerializer, RegisterBankAccountSerializer, TransactionCreateSerializer
from .services import upsert_cashflow_for_account


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

        saku_utama = Saku.objects.create(
            saku_name="Saku Utama",
            account=bank_account,
            category_name="Nabung",
            balance=0,
            is_primary=True
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

        cashflow = upsert_cashflow_for_account(account=account, month=month, year=year)

        output_serializer = CashFlowSerializer(cashflow)
        return Response(output_serializer.data, status=status.HTTP_200_OK)

class AccountDetailsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        accounts = BankAccount.objects.filter(user=request.user)
        data = []
        for account in accounts:
            data.append({
                'id': account.id,
                'user_id': account.user_id,
                'user_name': account.user.name,
                'account_number': account.account_number,
                'card_number': account.card_number,
                'balance': str(account.balance),
            })
        return Response(data, status=status.HTTP_200_OK)
    
class TransactionCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TransactionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = BankAccount.objects.filter(
            id=validated_data['account_id'],
            user=request.user,
        ).first()

        if account is None:
            return Response(
                {'detail': 'Bank account not found or not owned by user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Logika untuk membuat transaksi baru
        # ...

        return Response({'detail': 'Transaction created successfully.'}, status=status.HTTP_201_CREATED)