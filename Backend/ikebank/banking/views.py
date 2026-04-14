import secrets
import uuid
from calendar import monthrange
from decimal import Decimal, ROUND_HALF_UP

from django.contrib.auth.hashers import check_password, make_password
from django.db import transaction
from django.db.models import Sum
from django.utils.dateparse import parse_date, parse_datetime
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import BankAccount, Beneficiaries, CardBlacklist, CardDetails, Deposito, Qris, Saku, Transaction, DepositoAccount
from .serializers import CashFlowCalculateSerializer, CashFlowSerializer, CheckRekeningSerializer, ForgotPinSerializer, QRISCheckSerializer, QrisLimitSerializer, RegisterBankAccountSerializer, TambahDanaSerializer, TransactionCreateSerializer, InternalTransferSerializer, TambahSakuSerializer, SakuDetailSerializer, TambahRekeningSerializer, CardRequestSerializer, CardEditSerializer, DepositoSerializer, DepositoAccountCreateSerializer, DepositoEstimateSerializer, DepositoEditSerializer, CardDetailsSerializer
from .services import get_cashflow_highlights, get_weekly_savings_recommendation, upsert_cashflow_for_account


def get_user_bank_account(user):
    return BankAccount.objects.filter(user=user).first()


def _generate_card_ccv():
    return f'{secrets.randbelow(1000):03d}'


def _generate_unique_card_number(prefix='4000', total_length=16, max_attempts=50):
    suffix_length = total_length - len(prefix)
    if suffix_length < 1:
        raise ValueError('prefix is too long for the requested total_length.')

    upper = (10 ** suffix_length) - 1

    for _ in range(max_attempts):
        suffix = str(secrets.randbelow(upper + 1)).zfill(suffix_length)
        card_number = f'{prefix}{suffix}'
        if (
            not BankAccount.objects.filter(card_number=card_number).exists()
            and not CardDetails.objects.filter(card_number=card_number).exists()
            and not CardBlacklist.objects.filter(card_number=card_number).exists()
        ):
            return card_number

    raise RuntimeError('Unable to generate unique card number at this time.')


def _generate_card_expiry_date(years_valid=5):
    expiry_date = timezone.localdate()
    try:
        return expiry_date.replace(year=expiry_date.year + years_valid)
    except ValueError:
        return expiry_date.replace(month=2, day=28, year=expiry_date.year + years_valid)


def _get_current_card_details(account):
    if account is None or not account.card_number:
        return None

    card_details = CardDetails.objects.filter(account=account, card_number=account.card_number).first()
    if card_details is not None:
        return card_details

    return CardDetails.objects.filter(account=account).order_by('-updated_at').first()


def _add_months(base_date, months):
    year = base_date.year + (base_date.month - 1 + months) // 12
    month = (base_date.month - 1 + months) % 12 + 1
    day = min(base_date.day, monthrange(year, month)[1])
    return base_date.replace(year=year, month=month, day=day)


def _get_previous_month_year(base_date):
    if base_date.month == 1:
        return 12, base_date.year - 1
    return base_date.month - 1, base_date.year


def _blacklist_card_number(card_number, reason='Blocked card'):
    normalized_card_number = (card_number or '').strip()
    if not normalized_card_number:
        return

    CardBlacklist.objects.get_or_create(
        card_number=normalized_card_number,
        defaults={'reason': reason},
    )


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

        with transaction.atomic():
            bank_account = BankAccount.objects.create(
                user=request.user,
                account_number=account_number,
                balance=0.00,
            )

            Saku.objects.create(
                saku_name="Saku Utama",
                account=bank_account,
                category_name="utama",
                balance=0,
                is_primary=True
            )

            Saku.objects.create(
                saku_name="Saku Celengan",
                account=bank_account,
                category_name="celengan",
                balance=0,
                is_primary=False
            )

        return Response({
            'id': bank_account.id,
            'account_number': bank_account.account_number,
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
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Aktivitas tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        current_date = timezone.localdate()
        month, year = current_date.month, current_date.year

        cashflow = upsert_cashflow_for_account(account=account, month=month, year=year)
        highlights = get_cashflow_highlights(account=account, month=month, year=year)

        output_serializer = CashFlowSerializer(cashflow)
        data = output_serializer.data
        data['highlights'] = highlights
        return Response(data, status=status.HTTP_200_OK)

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
                'qris_limit': account.qris_limit,
            })
        return Response(data, status=status.HTTP_200_OK)


class QrisDailyLimitView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Aktivitas tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        return Response({
            'qris_limit': account.qris_limit,
        }, status=status.HTTP_200_OK)

    def patch(self, request):
        serializer = QrisLimitSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Aktivitas tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        # pin = serializer.validated_data['pin']
        # pin = check_password(pin, request.user.pin)
        # if not pin:
        #     return Response(
        #         {'detail': 'PIN Salah! Silahkan masukkan PIN yang benar untuk mengubah limit QRIS.'},
        #         status=status.HTTP_400_BAD_REQUEST,
        #     )
        
        account.qris_limit = serializer.validated_data['qris_limit']

        if account.qris_limit < 0:
            return Response(
                {'detail': 'QRIS limit must be a non-negative integer.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if account.qris_limit > 10000000:
            return Response(
                {'detail': 'QRIS limit cannot exceed 10 million.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        account.save(update_fields=['qris_limit', 'updated_at'])

        return Response({
            'detail': 'QRIS limit updated successfully.',
            'qris_limit': account.qris_limit,
        }, status=status.HTTP_200_OK)
    
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
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Transaksi tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
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

        is_pin_valid = request.user.pin == pin or check_password(pin, request.user.pin)
        if not is_pin_valid:
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
                account = BankAccount.objects.select_for_update().select_related('user').filter(pk=account.pk).first()
                saku_utama = Saku.objects.select_for_update().filter(
                    account=account,
                    is_primary=True
                ).first()

                if account is None:
                    return Response(
                        {'detail': 'Bank account not found or not owned by user.'},
                        status=status.HTTP_404_NOT_FOUND,
                    )

                if saku_utama is None:
                    return Response(
                        {'detail': 'Primary Saku Utama not found.'},
                        status=status.HTTP_404_NOT_FOUND,
                    )

                destination_account = None
                destination_saku = None

                if category == 'payment':
                    qris_spent_today = Transaction.objects.filter(
                        account_id=account,
                        category='payment',
                        timestamp__date=timezone.localdate(),
                    ).aggregate(total=Sum('amount'))['total'] or 0

                    if qris_spent_today + amount > account.qris_limit:
                        remaining_limit = max(account.qris_limit - qris_spent_today, 0)
                        return Response(
                            {
                                'detail': 'QRIS daily limit exceeded.',
                                'qris_limit': account.qris_limit,
                                'qris_spent_today': qris_spent_today,
                                'remaining_limit': remaining_limit,
                            },
                            status=status.HTTP_400_BAD_REQUEST,
                        )

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
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Aktivitas tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
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
    - Saku Celengan/Nabung <-> Saku Utama
    - Any non-deposito Saku -> Saku Deposito
    Not allowed:
    - Saku Deposito -> anywhere
    - Non-primary -> non-primary (except when destination is deposito)
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
        if account.block:
            return Response(
                {'detail': 'Akun Anda sedang diblokir. Aktivitas tidak dapat diproses.'},
                status=status.HTTP_403_FORBIDDEN,
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

        source_is_deposito = _is_deposito_saku(source_saku)
        destination_is_deposito = _is_deposito_saku(destination_saku)

        # Deposito cannot send funds to any destination.
        if source_is_deposito:
            return Response(
                {'detail': 'Saku deposito tidak bisa mengirim dana.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Deposito can receive from any non-deposito source.
        if not destination_is_deposito:
            # Non-deposito can transfer to non-deposito freely.
            # Validate that non-primary sakus (if any) belong to allowed categories.
            for saku in [source_saku, destination_saku]:
                if not saku.is_primary:
                    saku_category = (saku.category_name or '').strip().lower()
                    if saku_category not in {'celengan', 'nabung', 'transaksi'}:
                        return Response(
                            {'detail': f'Saku {saku.saku_name} tidak bisa digunakan untuk transfer internal.'},
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
            with transaction.atomic():
                # Refresh objects to ensure latest balance before update
                source_saku.refresh_from_db()
                destination_saku.refresh_from_db()

                # Double-check balance after refresh
                if source_saku.balance < amount:
                    return Response(
                        {'detail': 'Insufficient balance in source Saku (after refresh).'},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                # Reduce source Saku
                source_saku.balance -= amount
                source_saku.save(update_fields=['balance'])

                # Increase destination Saku
                destination_saku.balance += amount
                destination_saku.save(update_fields=['balance'])

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


class SavingsRecommendationView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank account found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        recommendation = get_weekly_savings_recommendation(account=account)
        return Response(recommendation, status=status.HTTP_200_OK)


class NabungAIStateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        cooldown = request.user.nabung_ai_cooldown_until
        return Response(
            {
                'auto_isi': bool(request.user.nabung_ai_auto_isi),
                'cooldown_until': cooldown.isoformat() if cooldown else None,
            },
            status=status.HTTP_200_OK,
        )

    def post(self, request):
        auto_isi = request.data.get('auto_isi', None)
        cooldown_until = request.data.get('cooldown_until', None)
        clear_cooldown = request.data.get('clear_cooldown', False)

        update_fields = []

        if auto_isi is not None:
            if isinstance(auto_isi, bool):
                parsed_auto_isi = auto_isi
            elif isinstance(auto_isi, (int, float)):
                parsed_auto_isi = auto_isi != 0
            elif isinstance(auto_isi, str):
                parsed_auto_isi = auto_isi.strip().lower() in ('true', '1', 'yes', 'on')
            else:
                return Response(
                    {'detail': 'Invalid auto_isi value.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            request.user.nabung_ai_auto_isi = parsed_auto_isi
            update_fields.append('nabung_ai_auto_isi')

        if clear_cooldown:
            request.user.nabung_ai_cooldown_until = None
            update_fields.append('nabung_ai_cooldown_until')
        elif cooldown_until is not None:
            if cooldown_until in ('', None):
                request.user.nabung_ai_cooldown_until = None
                update_fields.append('nabung_ai_cooldown_until')
            else:
                parsed_cooldown = parse_datetime(str(cooldown_until))
                if parsed_cooldown is None:
                    return Response(
                        {'detail': 'Invalid cooldown_until datetime format.'},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                if timezone.is_naive(parsed_cooldown):
                    parsed_cooldown = timezone.make_aware(parsed_cooldown, timezone.get_current_timezone())

                request.user.nabung_ai_cooldown_until = parsed_cooldown
                update_fields.append('nabung_ai_cooldown_until')

        if update_fields:
            request.user.save(update_fields=update_fields + ['updated_at'])

        cooldown = request.user.nabung_ai_cooldown_until
        return Response(
            {
                'auto_isi': bool(request.user.nabung_ai_auto_isi),
                'cooldown_until': cooldown.isoformat() if cooldown else None,
            },
            status=status.HTTP_200_OK,
        )
    
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
    
class CheckRekeningView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CheckRekeningSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account_number = validated_data['account_number'].strip()

        if not account_number:
            return Response(
                {'detail': 'account_number is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        destination_account = BankAccount.objects.filter(account_number=account_number).first()
        if destination_account is None:
            return Response(
                {'detail': 'Destination account not found in BankAccount.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response({
            'account_number': destination_account.account_number,
            'bank_name': 'IKE Bank',
            'account_holder_name': destination_account.user.name,
        }, status=status.HTTP_200_OK)

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
    
class CardRequestView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CardRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Ambil Saku/source_funds sesuai source_funds_id
        source_funds_id = validated_data['source_funds_id'].strip()
        saku = Saku.objects.filter(account=account, id=source_funds_id).first()
        if saku is None:
            return Response(
                {'detail': 'Source Saku tidak ditemukan.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        if saku.balance < 50000:
            return Response(
                {'detail': 'Minimum balance of 50,000 is required in the selected Saku to request a card.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        cardholder_name = request.user.name.strip()
        pin = validated_data['pin'].strip()
        source_funds_id = validated_data['source_funds_id'].strip()

        if not check_password(pin, request.user.pin):
            return Response(
                {'detail': 'Invalid PIN.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        current_card_details = _get_current_card_details(account)
        if current_card_details is not None and not current_card_details.block_permanent:
            return Response({
                'detail': 'Card already exists.',
                'card_number': account.card_number,
                'expiry_date': current_card_details.expiry_date,
                'ccv': current_card_details.ccv,
                'card_status': current_card_details.card_status,
            }, status=status.HTTP_200_OK)

        new_card_number = _generate_unique_card_number()
        account.card_number = new_card_number
        account.save(update_fields=['card_number'])

        card_details = CardDetails.objects.create(
            account=account,
            card_number=new_card_number,
            cardholder_name=cardholder_name,
            source_funds_id=source_funds_id,

            ccv=_generate_card_ccv(),
            card_status='requested',
            expiry_date=_generate_card_expiry_date(),
        )

        return Response({
            'card_number': account.card_number,
            'expiry_date': card_details.expiry_date,
            'ccv': card_details.ccv,
            'added_at': card_details.added_at,
            'updated_at': card_details.updated_at,
            'detail': 'Card requested successfully.',
        }, status=status.HTTP_201_CREATED)


class CardDetailsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    PIN_REQUIRED_STATUSES = {'active', 'blocked', 'blocked_temporary'}

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not account.card_number:
            return Response({'card_status': 'none'}, status=status.HTTP_200_OK)

        card_details = _get_current_card_details(account)
        if card_details is None:
            return Response({'card_status': 'none'}, status=status.HTTP_200_OK)

        return Response({
            'card_number': account.card_number,
            'card_status': card_details.card_status,
            'requires_pin': card_details.card_status in self.PIN_REQUIRED_STATUSES,
        }, status=status.HTTP_200_OK)

    def post(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not account.card_number:
            return Response(
                {'detail': 'No card associated with this account.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        card_details = _get_current_card_details(account)
        if card_details is None:
            return Response(
                {'detail': 'Card details not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        card_status = (card_details.card_status or '').strip().lower()
        if card_status not in self.PIN_REQUIRED_STATUSES:
            return Response(
                {
                    'detail': 'PIN hanya diperlukan ketika kartu sudah active atau blocked.',
                    'card_status': card_details.card_status,
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = CardDetailsSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        pin = serializer.validated_data['pin'].strip()

        if not request.user.pin:
            return Response(
                {'detail': 'PIN belum diset untuk user ini.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        is_pin_valid = request.user.pin == pin or check_password(pin, request.user.pin)
        if not is_pin_valid:
            return Response(
                {'detail': 'Invalid PIN.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        return Response({
            'card_number': account.card_number,
            'expiry_date': card_details.expiry_date,
            'ccv': card_details.ccv,
            'card_status': card_details.card_status,
        }, status=status.HTTP_200_OK)
    
class CardEditView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CardEditSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not account.card_number:
            return Response(
                {'detail': 'No card associated with this account.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        
        card_details = _get_current_card_details(account)
        if card_details is None:
            return Response(
                {'detail': 'Card details not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        action = validated_data['action']
        update_fields = []

        pin_required_actions = {
            CardEditSerializer.ACTION_BLOCK_TEMPORARY,
            CardEditSerializer.ACTION_UNBLOCK_TEMPORARY,
            CardEditSerializer.ACTION_BLOCK_PERMANENT,
            CardEditSerializer.ACTION_SET_DAILY_LIMIT,
        }
        if action in pin_required_actions:
            submitted_pin = (validated_data.get('pin') or '').strip()
            if not request.user.pin:
                return Response(
                    {'detail': 'PIN belum diset untuk user ini.'},
                    status=status.HTTP_404_NOT_FOUND,
                )

            is_pin_valid = request.user.pin == submitted_pin or check_password(
                submitted_pin,
                request.user.pin,
            )
            if not is_pin_valid:
                return Response(
                    {'detail': 'Invalid PIN.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        if action == CardEditSerializer.ACTION_BLOCK_TEMPORARY:
            if card_details.card_status != 'active':
                return Response(
                    {'detail': 'Only active card can be blocked temporarily.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if card_details.block_permanent:
                return Response(
                    {'detail': 'Card is permanently blocked and cannot be temporarily blocked/unblocked.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            card_details.block_temporary = True
            card_details.block_permanent = False
            card_details.card_status = 'blocked_temporary'
            update_fields.extend(['block_temporary', 'card_status'])

        elif action == CardEditSerializer.ACTION_UNBLOCK_TEMPORARY:
            if card_details.block_permanent:
                return Response(
                    {'detail': 'Card is permanently blocked and cannot be unblocked.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            card_details.block_temporary = False
            card_details.card_status = 'active'
            update_fields.extend(['block_temporary', 'card_status'])

        elif action == CardEditSerializer.ACTION_BLOCK_PERMANENT:
            if card_details.card_status == 'requested':
                return Response(
                    {'detail': 'Only active card can be blocked permanently.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            card_details.block_permanent = True
            card_details.block_temporary = False
            card_details.card_status = 'blocked'
            account.card_number = ''
            update_fields.extend(['block_permanent', 'block_temporary', 'card_status'])
            _blacklist_card_number(account.card_number, reason='Blocked permanently by user action.')

        elif action == CardEditSerializer.ACTION_SET_DAILY_LIMIT:
            if card_details.card_status != 'active':
                return Response(
                    {'detail': 'Only active card can change limits.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if card_details.block_permanent:
                return Response(
                    {'detail': 'Permanent blocked card cannot change limits.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            for field_name in (
                'daily_withdrawal_limit',
                'daily_transaction_limit',
                'daily_single_transaction_limit',
            ):
                if field_name in validated_data:
                    setattr(card_details, field_name, validated_data[field_name])
                    update_fields.append(field_name)

        elif action == CardEditSerializer.ACTION_CHANGE_CARD_PIN:
            if card_details.block_permanent:
                return Response(
                    {'detail': 'Permanent blocked card cannot change PIN.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            old_pin = validated_data['old_pin'].strip()
            new_pin = validated_data['new_pin'].strip()

            is_old_pin_valid = card_details.pin == old_pin or check_password(old_pin, card_details.pin)
            if not is_old_pin_valid:
                return Response(
                    {'detail': 'Old PIN is invalid.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if old_pin == new_pin:
                return Response(
                    {'detail': 'New PIN must be different from old PIN.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            card_details.pin = make_password(new_pin)
            update_fields.append('pin')

        elif action == CardEditSerializer.ACTION_VERIFY_CARD:
            submitted_last6 = (validated_data.get('card_last6_digits') or '').strip()
            expected_last6 = (account.card_number or '')[-6:]
            if submitted_last6 != expected_last6:
                return Response(
                    {'detail': 'Last 6 card digits do not match.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            return Response({
                'detail': 'Card verification successful.',
                'action': action,
                'verified': True,
                'card_number': account.card_number,
                'card_status': card_details.card_status,
            }, status=status.HTTP_200_OK)

        elif action == CardEditSerializer.ACTION_ACTIVATE_CARD:
            if card_details.block_permanent:
                return Response(
                    {'detail': 'Permanent blocked card cannot be activated.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            submitted_last6 = (validated_data.get('card_last6_digits') or '').strip()
            expected_last6 = (account.card_number or '')[-6:]
            if submitted_last6 != expected_last6:
                return Response(
                    {'detail': 'Last 6 card digits do not match.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if card_details.card_status == 'active':
                return Response(
                    {'detail': 'Card is already active.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            new_pin = validated_data['new_pin'].strip()
            card_details.pin = make_password(new_pin)
            card_details.card_status = 'active'
            card_details.block_temporary = False
            update_fields.extend(['pin', 'card_status', 'block_temporary'])

        elif action == CardEditSerializer.ACTION_CHANGE_STATUS:
            target_status = validated_data['status']
            if target_status not in dict(CardDetails.CARD_STATUS_CHOICES):
                return Response(
                    {'detail': 'Invalid card status.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if target_status == 'blocked' :
                return Response(
                    {'detail': 'Only active card can be changed to blocked status.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if card_details.block_permanent and target_status != 'blocked':
                return Response(
                    {'detail': 'Permanent blocked card status cannot be changed to non-blocked.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if target_status == 'active':
                return Response(
                    {'detail': 'Use ACTIVATE_CARD to activate card and set first PIN.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            card_details.card_status = target_status
            update_fields.append('card_status')
            if target_status == 'blocked':
                _blacklist_card_number(account.card_number, reason='Blocked via CHANGE_STATUS action.')


        if update_fields:
            card_details.save(update_fields=update_fields)

        # Save account if card_number was cleared during blocking
        if account.card_number == '':
            account.save(update_fields=['card_number'])

        return Response({
            'detail': 'Card details updated successfully.',
            'action': action,
            'card_number': account.card_number,
            'card_status': card_details.card_status,
            'block_temporary': card_details.block_temporary,
            'block_permanent': card_details.block_permanent,
            'daily_withdrawal_limit': card_details.daily_withdrawal_limit,
            'daily_transaction_limit': card_details.daily_transaction_limit,
            'daily_single_transaction_limit': card_details.daily_single_transaction_limit,
            'expiry_date': card_details.expiry_date,
            'ccv': card_details.ccv,
        }, status=status.HTTP_200_OK)
    
class DepositoListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        depositos = Deposito.objects.all().order_by('interest_rate')
        serializer = DepositoSerializer(depositos, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class DepositoEstimateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = DepositoEstimateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        deposito_id = validated_data['deposito_id']
        source_saku_id = validated_data['source_saku_id']
        amount = validated_data['amount']

        deposito_type = Deposito.objects.filter(deposito_id=deposito_id).first()
        if deposito_type is None:
            return Response(
                {'detail': 'Deposito menu not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        source_saku = Saku.objects.filter(id=source_saku_id, account=account).first()
        if source_saku is None:
            return Response(
                {'detail': 'Source saku not found.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        source_category = (source_saku.category_name or '').strip().lower()
        if source_category == 'celengan':
            return Response(
                {'detail': 'Saku Celengan tidak bisa digunakan untuk membuat deposito.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        is_allowed_source = source_saku.is_primary or source_category in {'nabung', 'transaksi'}
        if not is_allowed_source:
            return Response(
                {'detail': 'Sumber dana deposito hanya boleh dari Saku Utama, Nabung, atau Transaksi.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if amount > 100000000:
            return Response(
                {'detail': 'Maximum amount for this deposito type is 100,000,000.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        amount_decimal = Decimal(str(amount))
        annual_rate = Decimal(str(deposito_type.interest_rate))
        duration_months = int(deposito_type.duratuion_months)

        gross_interest = (
            amount_decimal * (annual_rate / Decimal('100')) * (Decimal(duration_months) / Decimal('12'))
        ).quantize(Decimal('1'), rounding=ROUND_HALF_UP)
        tax_amount = (gross_interest * Decimal('0.20')).quantize(Decimal('1'), rounding=ROUND_HALF_UP)
        net_interest = gross_interest - tax_amount
        maturity_estimation = amount_decimal + net_interest

        start_date = timezone.localdate()
        end_date = _add_months(start_date, duration_months)

        can_create = source_saku.balance >= amount

        return Response(
            {
                'deposito_id': deposito_type.deposito_id,
                'deposito_name': f'Deposito {duration_months} Bulan',
                'source_saku_id': source_saku.id,
                'source_saku_name': source_saku.saku_name,
                'amount': int(amount_decimal),
                'interest_rate_pa': str(annual_rate),
                'duration_months': duration_months,
                'gross_interest': int(gross_interest),
                'tax_percent': 20,
                'tax_amount': int(tax_amount),
                'net_interest': int(net_interest),
                'maturity_estimation': int(maturity_estimation),
                'start_date': start_date,
                'end_date': end_date,
                'source_saku_balance': source_saku.balance,
                'can_create': can_create,
            },
            status=status.HTTP_200_OK,
        )
    
class DepositoCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = DepositoAccountCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        deposito_id = validated_data['deposito_id']
        source_saku_id = validated_data['source_saku_id']
        amount = validated_data['amount']

        source_saku = Saku.objects.filter(id=source_saku_id, account=account).first()
        if source_saku is None:
            return Response(
                {'detail': 'Source saku not found.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        source_category = (source_saku.category_name or '').strip().lower()
        if source_category == 'celengan':
            return Response(
                {'detail': 'Saku Celengan tidak bisa digunakan untuk membuat deposito.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        is_allowed_source = source_saku.is_primary or source_category in {'nabung', 'transaksi'}
        if not is_allowed_source:
            return Response(
                {'detail': 'Sumber dana deposito hanya boleh dari Saku Utama, Nabung, atau Transaksi.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if amount < 1000000:
            return Response(
                {'detail': 'Minimum amount for this deposito type is 1,000,000.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        elif amount > 100000000:
            return Response(
                {'detail': 'Maximum amount for this deposito type is 100,000,000.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if source_saku.balance < amount:
            return Response(
                {'detail': 'Insufficient balance in source saku.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            deposito_type = Deposito.objects.select_for_update().filter(deposito_id=deposito_id).first()
            if deposito_type is None:
                return Response(
                    {'detail': 'Deposito menu not found.'},
                    status=status.HTTP_404_NOT_FOUND,
                )

            # Special offer or quota-based deposito will consume one quota slot per creation.
            if deposito_type.isSpecial and deposito_type.quota is None:
                return Response(
                    {'detail': 'Special offer deposito quota is not configured.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if deposito_type.quota is not None:
                if deposito_type.quota <= 0:
                    return Response(
                        {'detail': 'Deposito quota is full.'},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                deposito_type.quota -= 1
                deposito_type.save(update_fields=['quota'])

            source_saku.balance -= amount
            source_saku.save(update_fields=['balance'])

            new_deposito = DepositoAccount.objects.create(
                deposito_id=deposito_type,
                account_id=account,
                balance=amount,
                start_date=timezone.now().date(),
                end_date=timezone.now().date() + timezone.timedelta(days=deposito_type.duratuion_months * 30),
                deposito_name=f'Deposito {deposito_type.duratuion_months} Bulan',
            )

        return Response(
            {
                'deposito_account_id': new_deposito.deposito_account_id,
                'deposito_id': deposito_type.deposito_id,
                'source_saku_id': source_saku.id,
                'amount': new_deposito.balance,
                'start_date': new_deposito.start_date,
                'end_date': new_deposito.end_date,
                'deposito_name': new_deposito.deposito_name,
                'source_saku_balance': source_saku.balance,
            },
            status=status.HTTP_201_CREATED,
        )
    
class DepositoUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        accounts = BankAccount.objects.filter(user=request.user)
        if not accounts.exists():
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        depositos = DepositoAccount.objects.filter(
            account_id__in=accounts,
        ).select_related('deposito_id').order_by('-start_date')
        data = []
        for deposito in depositos:
            data.append({
                'deposito_account_id': deposito.deposito_account_id,
                'deposito_id': deposito.deposito_id.deposito_id,
                'interest_rate': deposito.deposito_id.interest_rate,
                'balance': str(deposito.balance),
                'start_date': deposito.start_date,
                'end_date': deposito.end_date,
                'deposito_name': deposito.deposito_name,
            })
        return Response(data, status=status.HTTP_200_OK)
    
class DepositoDetailsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        deposito_account_id_raw = request.query_params.get('deposito_account_id')
        if not deposito_account_id_raw:
            return Response(
                {'detail': 'deposito_account_id query parameter is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            deposito_account_id = uuid.UUID(str(deposito_account_id_raw).strip())
        except (ValueError, TypeError, AttributeError):
            return Response(
                {'detail': 'Invalid deposito_account_id format.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        deposito = DepositoAccount.objects.filter(
            deposito_account_id=deposito_account_id,
            account_id=account,
        ).select_related('deposito_id').first()

        if deposito is None:
            return Response(
                {'detail': 'Deposito not found for this user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        today = timezone.localdate()
        remaining_days = max((deposito.end_date - today).days, 0)

        return Response(
            {
                'deposito_account_id': deposito.deposito_account_id,
                'deposito_id': deposito.deposito_id.deposito_id,
                'deposito_name': deposito.deposito_name,
                'interest_rate': deposito.deposito_id.interest_rate,
                'duration_months': deposito.deposito_id.duratuion_months,
                'balance': str(deposito.balance),
                'start_date': deposito.start_date,
                'end_date': deposito.end_date,
                'remaining_days': remaining_days,
            },
            status=status.HTTP_200_OK,
        )
        

class DepositoEditView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = DepositoEditSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        deposito_account_id = validated_data.get('deposito_account_id')
        deposito_id = validated_data.get('deposito_id')
        deposito_name = validated_data.get('nama_deposito', '').strip()

        deposito = None
        if deposito_account_id is not None:
            deposito = DepositoAccount.objects.filter(
                deposito_account_id=deposito_account_id,
                account_id=account,
            ).first()
        elif deposito_id is not None:
            deposito = (
                DepositoAccount.objects.filter(
                    account_id=account,
                    deposito_id__deposito_id=deposito_id,
                )
                .order_by('-start_date', '-deposito_account_id')
                .first()
            )

        if deposito is None:
            return Response(
                {'detail': 'Deposito not found for this user.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if deposito_name:
            deposito.deposito_name = deposito_name
            deposito.save(update_fields=['deposito_name'])

        return Response(
            {
                'deposito_account_id': deposito.deposito_account_id,
                'deposito_name': deposito.deposito_name,
                'detail': 'Deposito updated successfully.',
            },
            status=status.HTTP_200_OK,
        )
        

class CardDailyLimitView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not account.card_number:
            return Response(
                {'detail': 'No card associated with this account.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        card_details = _get_current_card_details(account)
        if card_details is None:
            return Response(
                {'detail': 'Card details not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response({
            'daily_withdrawal_limit': card_details.daily_withdrawal_limit,
            'daily_transaction_limit': card_details.daily_transaction_limit,
            'daily_single_transaction_limit': card_details.daily_single_transaction_limit,
        }, status=status.HTTP_200_OK)
    
class ForgotPinView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ForgotPinSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)
        if account is None:
            return Response(
                {'detail': 'No bank accounts found for user.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        new_pin = validated_data['new_pin'].strip()
        new_pin_confirm = validated_data['new_pin_confirm'].strip()

        if new_pin != new_pin_confirm:
            return Response(
                {'detail': 'New PIN and confirmation do not match.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if len(new_pin) < 6 or len(new_pin) > 12:
            return Response(
                {'detail': 'PIN must be between 6 and 12 characters long.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        request.user.pin = make_password(new_pin)
        request.user.save(update_fields=['pin'])

        return Response({'detail': 'PIN updated successfully.'}, status=status.HTTP_200_OK)
    
class BlockAccountView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        account = BankAccount.objects.filter(user=request.user).first()
        if not account:
            return Response({'detail': 'Bank account not found for this user.'}, status=status.HTTP_404_NOT_FOUND)

        account.block = True
        account.save()

        return Response({'detail': 'Account has been blocked successfully.'}, status=status.HTTP_200_OK)