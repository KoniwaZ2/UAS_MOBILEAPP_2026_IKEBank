from django.contrib import admin
from .models import BankAccount, Transaction, CashFlow, TransactionCategory

@admin.register(BankAccount)
class BankAccountAdmin(admin.ModelAdmin):
    list_display = ('user', 'account_number', 'card_number', 'balance', 'created_at', 'updated_at')
    search_fields = ('user__name', 'account_number', 'card_number')
    list_filter = ('created_at', 'updated_at')

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('account_id', 'category_id', 'amount', 'balance_after', 'timestamp')
    search_fields = ('account_id__account_number', 'category_id__category_name')
    list_filter = ('timestamp',)

@admin.register(CashFlow)
class CashFlowAdmin(admin.ModelAdmin):
    list_display = ('account_id', 'total_income', 'total_expense', 'month', 'year', 'status')
    search_fields = ('account_id__account_number',)
    list_filter = ('month', 'year', 'status')

@admin.register(TransactionCategory)
class TransactionCategoryAdmin(admin.ModelAdmin):
    list_display = ('category_name', 'direction')
    search_fields = ('category_name',)
    list_filter = ('direction',)