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
