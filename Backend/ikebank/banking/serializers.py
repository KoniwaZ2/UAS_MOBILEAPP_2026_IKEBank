from rest_framework import serializers

from .models import BankAccount, CashFlow, Saku, Transaction


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
    """Transfer between Sakus - only between Saku Utama and other Sakus"""
    source_saku_id = serializers.IntegerField(required=True)  # From Saku (should be Utama)
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