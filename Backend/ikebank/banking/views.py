import secrets

from django.contrib.auth.hashers import check_password
from django.db import transaction
from django.utils.dateparse import parse_date
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import BankAccount, Beneficiaries, Qris, Saku, Transaction
from .serializers import CashFlowCalculateSerializer, CashFlowSerializer, QRISCheckSerializer, RegisterBankAccountSerializer, TambahDanaSerializer, TransactionCreateSerializer, InternalTransferSerializer, TambahSakuSerializer, SakuDetailSerializer, TambahRekeningSerializer
from .services import upsert_cashflow_for_account


def get_user_bank_account(user):
    return BankAccount.objects.filter(user=user).first()


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
            category_name="nabung",
            balance=0,
            is_primary=True
        )

        saku_celengan = Saku.objects.create(
            saku_name="Saku Celengan",
            account=bank_account,
            category_name="celengan",
            balance=0,
            is_primary=False
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

        account = get_user_bank_account(request.user)

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

        account = get_user_bank_account(request.user)

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
        pin = validated_data['pin']
        qris_merchant = None

        if not request.user.pin:
            return Response(
                {'detail': 'PIN belum diset untuk user ini.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if not check_password(pin, request.user.pin):
            return Response(
                {'detail': 'Invalid PIN.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if category == 'payment':
            qris_merchant = Qris.objects.filter(qris_number=merchant_qris).first()
            if qris_merchant is None:
                return Response(
                    {'detail': 'QRIS merchant not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

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
                source_funds = destination_account_number or merchant_qris
                if category == 'payment' and qris_merchant is not None:
                    source_funds = qris_merchant.merchant_name

                description = (validated_data.get('description') or '').strip()
                if category == 'payment' and qris_merchant is not None:
                    if not description or merchant_qris in description:
                        description = f'Pembayaran QRIS ke {qris_merchant.merchant_name}'

                sender_transaction = Transaction.objects.create(
                    account_id=account,
                    saku=saku_utama,
                    qris=qris_merchant if category == 'payment' else None,
                    category=category,
                    amount=amount,
                    balance_after=account.balance,
                    description=description,
                    source_funds=source_funds,
                    merchant_name_snapshot=qris_merchant.merchant_name if category == 'payment' and qris_merchant is not None else None,
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

                    Beneficiaries.objects.update_or_create(
                        account_id=account,
                        account_number=destination_account.account_number,
                        defaults={
                            'destination_account': destination_account,
                            'bank_name': 'IKE Bank',
                            'account_holder_name': destination_account.user.name,
                        },
                    )

                # Update cashflow untuk bulan ini
                from datetime import datetime
                now = datetime.now()
                upsert_cashflow_for_account(account=account, month=now.month, year=now.year)

                if category == 'transfer_out' and destination_account is not None:
                    upsert_cashflow_for_account(account=destination_account, month=now.month, year=now.year)

            return Response({
                'detail': 'Transaction completed successfully.',
                'transaction_id': sender_transaction.transaction_id.hex,
                'new_balance': account.balance,
                'saku_balance': saku_utama.balance,
                'transaction_time': sender_transaction.timestamp,
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

        account = get_user_bank_account(request.user)

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
                'transaction_id': transaction.transaction_id.hex,
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
    Internal transfer between Sakus.
    Allowed routes:
    - Any non-deposito Saku -> Saku Utama
    - Saku Utama -> any non-deposito Saku
    Not allowed:
    - Transfers involving deposito Sakus
    - Non-primary -> non-primary
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = InternalTransferSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        # Get account
        account = get_user_bank_account(request.user)

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

        # Prevent self-transfer to avoid duplicate records without real balance movement.
        if source_saku.id == destination_saku.id:
            return Response(
                {'detail': 'Source and destination Saku must be different.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        def _is_deposito_saku(saku):
            category = (saku.category_name or '').strip().lower()
            name = (saku.saku_name or '').strip().lower()
            return category == 'deposito' or 'deposito' in name

        # Deposito is excluded from internal transfer policy.
        if _is_deposito_saku(source_saku) or _is_deposito_saku(destination_saku):
            return Response(
                {'detail': 'Internal transfer tidak berlaku untuk deposito.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Allowed paths only:
        # 1) any Saku -> Saku Utama
        # 2) Saku Utama -> any Saku
        # Therefore, non-primary -> non-primary is forbidden.
        if not source_saku.is_primary and not destination_saku.is_primary:
            return Response(
                {'detail': 'Transfer hanya boleh antara Saku Utama dan saku lainnya.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Saku Nabung can only receive funds from Saku Utama.
        if destination_saku.category_name == 'nabung' and not source_saku.is_primary:
            return Response(
                {'detail': 'Saku Nabung hanya bisa menerima dana dari Saku Utama.'},
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
                'transaction_id': transaction_out.transaction_id.hex,
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

        account = get_user_bank_account(request.user)

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
                {'detail': 'Invalid category_name. Use nabung, transaksi, or lainnya.'},
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
                'location': qris.location,
                'aquirer': qris.aquirer,
                'PAN_id': qris.PAN_id,
            },
            status=status.HTTP_200_OK,
        )
    
class HistoryTransactionView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank account found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        transactions = Transaction.objects.filter(account_id=account).select_related('qris', 'saku')

        saku_id_raw = request.query_params.get('saku_id')
        if saku_id_raw:
            try:
                saku_id = int(saku_id_raw)
            except (TypeError, ValueError):
                return Response(
                    {'detail': 'Invalid saku_id.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            transactions = transactions.filter(saku_id=saku_id)

        saku_name = (request.query_params.get('saku_name') or '').strip()
        if saku_name:
            transactions = transactions.filter(saku__saku_name__iexact=saku_name)

        category = (request.query_params.get('category') or '').strip()
        if category:
            transactions = transactions.filter(category=category)

        start_date_raw = (request.query_params.get('start_date') or '').strip()
        if start_date_raw:
            start_date = parse_date(start_date_raw)
            if start_date is None:
                return Response(
                    {'detail': 'Invalid start_date. Use YYYY-MM-DD.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            transactions = transactions.filter(timestamp__date__gte=start_date)

        end_date_raw = (request.query_params.get('end_date') or '').strip()
        if end_date_raw:
            end_date = parse_date(end_date_raw)
            if end_date is None:
                return Response(
                    {'detail': 'Invalid end_date. Use YYYY-MM-DD.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            transactions = transactions.filter(timestamp__date__lte=end_date)

        transactions = transactions.order_by('-timestamp')

        offset_raw = request.query_params.get('offset')
        limit_raw = request.query_params.get('limit')
        try:
            offset = int(offset_raw) if offset_raw is not None else 0
            if offset < 0:
                raise ValueError
        except (TypeError, ValueError):
            return Response(
                {'detail': 'Invalid offset.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            limit = int(limit_raw) if limit_raw is not None else None
            if limit is not None and limit < 1:
                raise ValueError
        except (TypeError, ValueError):
            return Response(
                {'detail': 'Invalid limit.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if limit is None:
            transactions = transactions[offset:]
        else:
            transactions = transactions[offset:offset + limit]

        # Fallback for legacy payment rows that only stored QRIS number in source_funds.
        legacy_qris_numbers = {
            (tx.source_funds or '').strip()
            for tx in transactions
            if tx.category == 'payment' and tx.qris_id is None and not tx.merchant_name_snapshot and (tx.source_funds or '').strip().isdigit()
        }
        legacy_qris_map = {
            q.qris_number: q.merchant_name
            for q in Qris.objects.filter(qris_number__in=legacy_qris_numbers)
        }

        data = []
        for tx in transactions:
            fallback_qris_number = (tx.source_funds or '').strip() if tx.category == 'payment' and (tx.source_funds or '').strip().isdigit() else None
            qris_number = tx.qris.qris_number if tx.qris else fallback_qris_number
            merchant_name = tx.merchant_name_snapshot or (tx.qris.merchant_name if tx.qris else legacy_qris_map.get(fallback_qris_number or ''))

            description = tx.description
            if tx.category == 'payment' and merchant_name:
                description = f'Pembayaran QRIS ke {merchant_name}'

            data.append({
                'transaction_id': tx.transaction_id.hex,
                'saku_id': tx.saku_id,
                'category': tx.category,
                'amount': str(tx.amount),
                'balance_after': str(tx.balance_after),
                'timestamp': tx.timestamp,
                'description': description,
                'source_funds': tx.source_funds,
                'qris_number': qris_number,
                'merchant_name': merchant_name,
                'saku_name': tx.saku.saku_name if tx.saku else None,
            })
        return Response(data, status=status.HTTP_200_OK)
    
class SakuView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        sakus = Saku.objects.filter(account=account)
        data = []
        for saku in sakus:
            data.append({
                'id': saku.id,
                'saku_name': saku.saku_name,
                'category_name': saku.category_name,
                'balance': str(saku.balance),
                'is_primary': saku.is_primary,
            })
        return Response(data, status=status.HTTP_200_OK)
    
class SakuDetailView(APIView):
    serializer_class = SakuDetailSerializer
    permission_classes = [permissions.IsAuthenticated]

    @staticmethod
    def _parse_saku_id(raw_id):
        if raw_id is None:
            return None
        try:
            return int(raw_id)
        except (TypeError, ValueError):
            return 'invalid'

    @staticmethod
    def _build_saku_response(saku):
        return {
            'id': saku.id,
            'saku_name': saku.saku_name,
            'category_name': saku.category_name,
            'balance': str(saku.balance),
            'is_primary': saku.is_primary,
        }

    def get(self, request, pk=None):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if pk is None:
            parsed_id = self._parse_saku_id(
                request.query_params.get('id') or request.query_params.get('pk')
            )
            if parsed_id == 'invalid':
                return Response(
                    {'detail': 'Invalid saku id.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            pk = parsed_id

        if pk is None:
            saku = Saku.objects.filter(account=account, is_primary=True).first()
        else:
            saku = Saku.objects.filter(account=account, id=pk).first()

        if saku is None:
            return Response(
                {'detail': 'Saku not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(self._build_saku_response(saku), status=status.HTTP_200_OK)

    def post(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        parsed_id = self._parse_saku_id(request.data.get('id') or request.data.get('pk'))
        if parsed_id == 'invalid':
            return Response(
                {'detail': 'Invalid saku id.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if parsed_id is None:
            saku = Saku.objects.filter(account=account, is_primary=True).first()
        else:
            saku = Saku.objects.filter(account=account, id=parsed_id).first()

        if saku is None:
            return Response(
                {'detail': 'Saku not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(self._build_saku_response(saku), status=status.HTTP_200_OK)
    
class RekeningListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        beneficiaries = Beneficiaries.objects.filter(account_id=account).select_related('destination_account')
        data = []
        for beneficiary in beneficiaries:
            data.append({
                'id': beneficiary.id,
                'account_number': beneficiary.account_number,
                'bank_name': beneficiary.bank_name,
                'account_holder_name': beneficiary.account_holder_name,
                'added_at': beneficiary.added_at,
            })
        return Response(data, status=status.HTTP_200_OK)

class TambahRekeningView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = TambahRekeningSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        account_number = validated_data['account_number'].strip()
        bank_name = (validated_data.get('bank_name') or 'IKE Bank').strip()

        if not account_number or not bank_name:
            return Response(
                {'detail': 'account_number and bank_name are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        destination_account = BankAccount.objects.filter(account_number=account_number).first()
        if destination_account is None:
            return Response(
                {'detail': 'Destination account not found in BankAccount.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        account_holder_name = destination_account.user.name

        if Beneficiaries.objects.filter(account_id=account, account_number=account_number).exists():
            return Response(
                {'detail': 'Beneficiary with this account number already exists.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        beneficiary = Beneficiaries.objects.create(
            account_id=account,
            destination_account=destination_account,
            account_number=account_number,
            bank_name=bank_name,
            account_holder_name=account_holder_name,
        )

        return Response({
            'id': beneficiary.id,
            'account_number': beneficiary.account_number,
            'bank_name': beneficiary.bank_name,
            'account_holder_name': beneficiary.account_holder_name,
            'added_at': beneficiary.added_at,
        }, status=status.HTTP_201_CREATED)