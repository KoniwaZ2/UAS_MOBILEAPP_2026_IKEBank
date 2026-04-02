import secrets

from django.db import transaction
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import BankAccount, Saku, Transaction
from .serializers import CashFlowCalculateSerializer, CashFlowSerializer, QRISCheckSerializer, RegisterBankAccountSerializer, TambahDanaSerializer, TransactionCreateSerializer, InternalTransferSerializer, TambahSakuSerializer
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
    """
    External transactions: Transfer Out, QRIS Payment, Withdrawal
    Only from Saku Utama (primary account)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TransactionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = BankAccount.objects.filter(
            id=request.data.get('account_id'),
            user=request.user,
        ).first()

        if account is None:
            return Response(
                {'detail': 'Bank account not found or not owned by user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Get Saku Utama (primary account)
        saku_utama = Saku.objects.filter(
            account=account,
            is_primary=True
        ).first()

        if saku_utama is None:
            return Response(
                {'detail': 'Primary Saku Utama not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        category = validated_data['category']
        amount = validated_data['amount']
        destination_account_number = validated_data.get('destination_account', '')
        merchant_qris = validated_data.get('merchant_qris', '')

        # Validasi: External transactions hanya dari Saku Utama
        if saku_utama.balance < amount:
            return Response(
                {'detail': 'Insufficient balance in Saku Utama.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            with transaction.atomic():
                destination_account = None
                destination_saku = None

                if category == 'transfer_out':
                    destination_account = BankAccount.objects.filter(
                        account_number=destination_account_number,
                    ).exclude(id=account.id).select_related('user').first()

                    if destination_account is None:
                        return Response(
                            {'detail': 'Destination account not found.'},
                            status=status.HTTP_404_NOT_FOUND,
                        )

                    destination_saku = Saku.objects.filter(
                        account=destination_account,
                        is_primary=True,
                    ).first()

                    if destination_saku is None:
                        return Response(
                            {'detail': 'Destination primary Saku not found.'},
                            status=status.HTTP_404_NOT_FOUND,
                        )

                # Kurangi saldo Saku Utama
                saku_utama.balance -= amount
                saku_utama.save()

                # Kurangi akun bank utama
                account.balance -= amount
                account.save()

                # Buat transaction record pengirim
                sender_transaction = Transaction.objects.create(
                    account_id=account,
                    saku=saku_utama,
                    category=category,
                    amount=amount,
                    balance_after=account.balance,
                    description=validated_data.get('description', ''),
                    source_funds=destination_account_number or merchant_qris,
                )

                # Jika transfer ke rekening lain, kredit rekening tujuan
                if category == 'transfer_out' and destination_account and destination_saku:
                    destination_saku.balance += amount
                    destination_saku.save()

                    destination_account.balance += amount
                    destination_account.save()

                    Transaction.objects.create(
                        account_id=destination_account,
                        saku=destination_saku,
                        category='transfer_in',
                        amount=amount,
                        balance_after=destination_account.balance,
                        description=validated_data.get('description', ''),
                        source_funds=account.account_number,
                    )

                # Update cashflow untuk bulan ini
                from datetime import datetime
                now = datetime.now()
                upsert_cashflow_for_account(account=account, month=now.month, year=now.year)

                if category == 'transfer_out' and destination_account is not None:
                    upsert_cashflow_for_account(account=destination_account, month=now.month, year=now.year)

            return Response({
                'detail': 'Transaction completed successfully.',
                'transaction_id': sender_transaction.id,
                'new_balance': account.balance,
                'saku_balance': saku_utama.balance
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'detail': f'Transaction failed: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST,
            )
    
class TambahDanaView(APIView):
    """
    External deposits: ATM deposit, Incoming transfer
    Money goes directly to Saku Utama (primary account)
    Usually called from backend/Postman for top-ups
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TambahDanaSerializer(data=request.data)
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

        # Get Saku Utama (primary account)
        saku_utama = Saku.objects.filter(
            account=account,
            is_primary=True
        ).first()

        if saku_utama is None:
            return Response(
                {'detail': 'Primary Saku Utama not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        amount = validated_data['amount']
        source = validated_data.get('source', 'ATM')

        try:
            # Tambah saldo Saku Utama
            saku_utama.balance += amount
            saku_utama.save()

            # Tambah saldo akun bank
            account.balance += amount
            account.save()

            # Buat transaction record (income category)
            transaction = Transaction.objects.create(
                account_id=account,
                saku=saku_utama,
                category='deposit',  # External deposit
                amount=amount,
                balance_after=account.balance,
                description=validated_data.get('description', f'External deposit from {source}'),
                source_funds=source
            )

            # Update cashflow untuk bulan ini
            from datetime import datetime
            now = datetime.now()
            upsert_cashflow_for_account(account=account, month=now.month, year=now.year)

            return Response({
                'detail': 'Funds added successfully to Saku Utama.',
                'transaction_id': transaction.id,
                'new_balance': account.balance,
                'saku_utama_balance': saku_utama.balance
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'detail': f'Failed to add funds: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST,
            )


class InternalTransferView(APIView):
    """
    Internal transfer between Sakus
    Restrictions:
    - Saku Nabung can ONLY receive from Saku Utama
    - Cannot transfer FROM Saku Nabung to anywhere
    - All other transfers between Sakus are allowed
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = InternalTransferSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        # Get account
        account = BankAccount.objects.filter(
            id=validated_data['account_id'],
            user=request.user,
        ).first()

        if account is None:
            return Response(
                {'detail': 'Bank account not found or not owned by user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Get source Saku
        source_saku = Saku.objects.filter(
            id=validated_data['source_saku_id'],
            account=account,
        ).first()

        if source_saku is None:
            return Response(
                {'detail': 'Source Saku not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Get destination Saku
        destination_saku = Saku.objects.filter(
            id=validated_data['destination_saku_id'],
            account=account,
        ).first()

        if destination_saku is None:
            return Response(
                {'detail': 'Destination Saku not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # VALIDATION: Saku Nabung restrictions
        # 1. Cannot transfer FROM Saku Nabung
        if source_saku.category_name == "Nabung":
            return Response(
                {'detail': 'Cannot transfer FROM Saku Nabung. Saku Nabung is for savings only.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 2. Only Saku Utama can send to other Sakus
        if not source_saku.is_primary:
            return Response(
                {'detail': 'Only Saku Utama can transfer to other Sakus.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # 3. If destination is Saku Nabung, source must be Saku Utama (already checked above)
        if destination_saku.category_name == "Nabung" and not source_saku.is_primary:
            return Response(
                {'detail': 'Can only transfer TO Saku Nabung from Saku Utama.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        amount = validated_data['amount']

        # Check sufficient balance
        if source_saku.balance < amount:
            return Response(
                {'detail': 'Insufficient balance in source Saku.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Reduce source Saku
            source_saku.balance -= amount
            source_saku.save()

            # Increase destination Saku
            destination_saku.balance += amount
            destination_saku.save()

            # Create transaction record for source (outgoing)
            transaction_out = Transaction.objects.create(
                account_id=account,
                saku=source_saku,
                category='other',  # Internal transfer
                amount=amount,
                balance_after=source_saku.balance,
                description=f'Transfer to {destination_saku.saku_name}' + (f': {validated_data.get("description", "")}' if validated_data.get('description') else ''),
                source_funds=f'Internal transfer to {destination_saku.saku_name}'
            )

            # Create transaction record for destination (incoming)
            transaction_in = Transaction.objects.create(
                account_id=account,
                saku=destination_saku,
                category='other',  # Internal transfer
                amount=amount,
                balance_after=destination_saku.balance,
                description=f'Transfer from {source_saku.saku_name}' + (f': {validated_data.get("description", "")}' if validated_data.get('description') else ''),
                source_funds=f'Internal transfer from {source_saku.saku_name}'
            )

            return Response({
                'detail': 'Internal transfer completed successfully.',
                'transaction_id': transaction_out.id,
                'source_saku': {
                    'id': source_saku.id,
                    'name': source_saku.saku_name,
                    'balance': source_saku.balance
                },
                'destination_saku': {
                    'id': destination_saku.id,
                    'name': destination_saku.saku_name,
                    'balance': destination_saku.balance
                },
                'amount_transferred': amount
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'detail': f'Transfer failed: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST,
            )

class TambahSakuView(APIView):
    """
    Add new Saku to the same account
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TambahSakuSerializer(data=request.data)
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

        category_name = validated_data['category_name']
        saku_name = validated_data['saku_name'].strip()
        is_primary = validated_data.get('is_primary', False)

        if category_name not in dict(Saku.CATEGORY_CHOICES):
            return Response(
                {'detail': 'Invalid category_name. Use Nabung, Transaksi, or Lainnya.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not saku_name:
            return Response(
                {'detail': 'saku_name cannot be empty.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if saku_name == "Saku Utama":
            return Response(
                {'detail': 'saku_name "Saku Utama" is reserved for the primary Saku.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        if Saku.objects.filter(account=account, saku_name=saku_name).exists():
            return Response(
                {'detail': 'Saku name already exists for this account. Choose a different name.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if is_primary and Saku.objects.filter(account=account, is_primary=True).exists():
            return Response(
                {'detail': 'Primary Saku already exists for this account.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        saku = Saku.objects.create(
            saku_name=saku_name,
            account=account,
            category_name=category_name,
            balance=0,
            is_primary=is_primary,
        )

        return Response(
            {
                'id': saku.id,
                'account_id': account.id,
                'saku_name': saku.saku_name,
                'category_name': saku.category_name,
                'balance': saku.balance,
                'is_primary': saku.is_primary,
                'created_at': saku.created_at,
                'updated_at': saku.updated_at,
            },
            status=status.HTTP_201_CREATED,
        )

class QrisCheckView(APIView):
    """
    Check if a QRIS number is registered in the system
    """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = QRISCheckSerializer

    def post(self, request):
        serializer = QRISCheckSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        qris_number = validated_data.get('qris_number')

        if not qris_number:
            return Response(
                {'detail': 'qris_number is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        from .models import Qris
        qris = Qris.objects.filter(qris_number=qris_number).first()

        if qris is None:
            return Response(
                {'detail': 'QRIS number not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(
            {
                'qris_number': qris.qris_number,
                'merchant_name': qris.merchant_name,
            },
            status=status.HTTP_200_OK,
        )