from rest_framework import serializers

from .models import BankAccount, CashFlow


class RegisterBankAccountSerializer(serializers.Serializer):
    pass


class CashFlowCalculateSerializer(serializers.Serializer):
    account_id = serializers.IntegerField(required=True)
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
    saku_id = serializers.IntegerField(required=True)
    category_id = serializers.IntegerField(required=True)
    amount = serializers.IntegerField(required=True)
    description = serializers.CharField(required=False, allow_blank=True)
    source_funds = serializers.CharField(required=False, allow_blank=True)