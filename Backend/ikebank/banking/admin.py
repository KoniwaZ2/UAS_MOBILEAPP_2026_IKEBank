from django.contrib import admin
from .models import BankAccount, Transaction, CashFlow, CardDetails, Saku, Qris

@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = ('user', 'account_number', 'card_number', 'balance', 'created_at', 'updated_at')
    search_fields = ('user__name', 'account_number', 'card_number')
    list_filter = ('created_at', 'updated_at')

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_id', 'account_id', 'category', 'amount', 'balance_after', 'timestamp')
    search_fields = ('account_id__account_number', 'category')
    list_filter = ('timestamp',)

@admin.register(CashFlow)
class CashFlowAdmin(admin.ModelAdmin):
    list_display = ('account_id', 'total_income', 'total_expense', 'month', 'year', 'status')
    search_fields = ('account_id__account_number',)
    list_filter = ('month', 'year', 'status')

@admin.register(CardDetails)
class CardDetailsAdmin(admin.ModelAdmin):
    list_display = ('account_id', 'cardholder_name', 'ccv', 'expiry_date', 'block_permanent', 'block_temporary')
    search_fields = ('account_id__account_number', 'account_id__card_number', 'cardholder_name')
    list_filter = ('block_permanent', 'block_temporary', 'expiry_date')

@admin.register(Saku)
class SakuAdmin(admin.ModelAdmin):
    list_display = ('id', 'saku_name', 'account', 'category_name', 'balance', 'is_primary')
    search_fields = ('saku_name', 'account__account_number', 'category_name')
    list_filter = ('is_primary',)

@admin.register(Qris)
class QrisAdmin(admin.ModelAdmin):
    list_display = ('merchant_name', 'qris_number')
    search_fields = ('merchant_name', 'qris_number')

class BeneficiariesAdmin(admin.ModelAdmin):
    list_display = ('account_id', 'bank_name', 'alias', 'added_at')
    search_fields = ('account_id__account_number', 'alias')
    list_filter = ('added_at',)