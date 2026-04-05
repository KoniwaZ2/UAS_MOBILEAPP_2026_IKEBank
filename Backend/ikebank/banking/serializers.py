from rest_framework import serializers

from .models import BankAccount, CardDetails, CashFlow, Saku, Transaction


class RegisterBankAccountSerializer(serializers.Serializer):
    pass


class CashFlowCalculateSerializer(serializers.Serializer):
    month = serializers.IntegerField(min_value=1, max_value=12, required=True)
    year = serializers.IntegerField(min_value=2000, max_value=2100, required=True)


class CashFlowSerializer(serializers.ModelSerializer):
    class Meta:
        model = CashFlow
        fields = [
            'id',
            'account_id',
            'total_income',
            'total_expense',
            'month',
            'year',
            'status',
        ]

class TransactionCreateSerializer(serializers.Serializer):
    pin = serializers.CharField(required=True)
    category = serializers.ChoiceField(choices=Transaction.CATEGORY_CHOICES, required=True)
    amount = serializers.IntegerField(required=True)
    description = serializers.CharField(required=False, allow_blank=True)
    destination_account = serializers.CharField(required=False, allow_blank=True)  # For transfer_out
    merchant_qris = serializers.CharField(required=False, allow_blank=True)  # For payment

    def validate(self, attrs):
        category = attrs.get('category')
        destination_account = attrs.get('destination_account')
        merchant_qris = attrs.get('merchant_qris')

        if category == 'transfer_out' and not destination_account:
            raise serializers.ValidationError({'destination_account': 'Wajib diisi untuk transfer_out.'})

        if category == 'payment' and not merchant_qris:
            raise serializers.ValidationError({'merchant_qris': 'Wajib diisi untuk payment.'})

        return attrs

class TambahDanaSerializer(serializers.Serializer):
    """External deposits to primary Saku Utama (ATM, incoming transfer)"""
    amount = serializers.IntegerField(required=True)
    description = serializers.CharField(required=False, allow_blank=True)
    source = serializers.CharField(required=False, allow_blank=True)  # ATM, Transfer In, etc

class InternalTransferSerializer(serializers.Serializer):
    """Transfer between Sakus - only between Saku Utama and non-deposito Sakus"""
    source_saku_id = serializers.IntegerField(required=True)  # From Saku
    destination_saku_id = serializers.IntegerField(required=True)  # To Saku
    amount = serializers.IntegerField(required=True)
    description = serializers.CharField(required=False, allow_blank=True)

class TambahSakuSerializer(serializers.Serializer):
    """Add new Saku to existing Bank Account"""
    saku_name = serializers.CharField(required=True)
    category_name = serializers.ChoiceField(choices=Saku.CATEGORY_CHOICES, required=True)
    is_primary = serializers.BooleanField(required=False, default=False)

class QRISCheckSerializer(serializers.Serializer):
    qris_number = serializers.CharField(required=True)

class SakuDetailSerializer(serializers.ModelSerializer):
    saku_id = serializers.IntegerField(source='id')

class TambahRekeningSerializer(serializers.Serializer):
    account_number = serializers.CharField(required=True)
    bank_name = serializers.CharField(required=False, default='IKE Bank')

class CardRequestSerializer(serializers.Serializer):
    pin = serializers.CharField(max_length=6, min_length=6, required=True)
    cardholder_name = serializers.CharField(required=False, allow_blank=False)

class CardEditSerializer(serializers.Serializer):
    ACTION_BLOCK_TEMPORARY = 'BLOCK_TEMPORARY'
    ACTION_UNBLOCK_TEMPORARY = 'UNBLOCK_TEMPORARY'
    ACTION_BLOCK_PERMANENT = 'BLOCK_PERMANENT'
    ACTION_SET_DAILY_LIMIT = 'SET_DAILY_LIMIT'
    ACTION_CHANGE_CARD_PIN = 'CHANGE_CARD_PIN'
    ACTION_CHANGE_STATUS = 'CHANGE_STATUS'

    ACTION_CHOICES = [
        (ACTION_BLOCK_TEMPORARY, ACTION_BLOCK_TEMPORARY),
        (ACTION_UNBLOCK_TEMPORARY, ACTION_UNBLOCK_TEMPORARY),
        (ACTION_BLOCK_PERMANENT, ACTION_BLOCK_PERMANENT),
        (ACTION_SET_DAILY_LIMIT, ACTION_SET_DAILY_LIMIT),
        (ACTION_CHANGE_CARD_PIN, ACTION_CHANGE_CARD_PIN),
        (ACTION_CHANGE_STATUS, ACTION_CHANGE_STATUS),
    ]

    action = serializers.ChoiceField(choices=ACTION_CHOICES, required=True)
    old_pin = serializers.CharField(max_length=6, min_length=6, required=False, allow_blank=False)
    new_pin = serializers.CharField(max_length=6, min_length=6, required=False, allow_blank=False)
    daily_withdrawal_limit = serializers.IntegerField(required=False, min_value=0)
    daily_transaction_limit = serializers.IntegerField(required=False, min_value=0)
    daily_single_transaction_limit = serializers.IntegerField(required=False, min_value=0)
    status = serializers.ChoiceField(choices=CardDetails.CARD_STATUS_CHOICES, required=False)
    card_last6_digits = serializers.CharField(max_length=6, min_length=6, required=False, allow_blank=False)

    def validate(self, attrs):
        action = attrs.get('action')

        if action == self.ACTION_CHANGE_CARD_PIN:
            if not attrs.get('old_pin') or not attrs.get('new_pin'):
                raise serializers.ValidationError({'detail': 'old_pin and new_pin are required for CHANGE_CARD_PIN.'})

        if action == self.ACTION_SET_DAILY_LIMIT:
            has_any_limit = any(
                key in attrs
                for key in ('daily_withdrawal_limit', 'daily_transaction_limit', 'daily_single_transaction_limit')
            )
            if not has_any_limit:
                raise serializers.ValidationError({'detail': 'At least one limit value is required for SET_DAILY_LIMIT.'})

        if action == self.ACTION_CHANGE_STATUS and not attrs.get('status'):
            raise serializers.ValidationError({'detail': 'status is required for CHANGE_STATUS.'})

        return attrs