from django.db.models import Q, Sum, Value
from django.db.models.functions import Coalesce

from .models import BankAccount, CashFlow, Transaction


def calculate_cashflow_status(total_income, total_expense):
    if total_income <= 0:
        return 'belum_optimal'

    saving_rate = (total_income - total_expense) / total_income
    if saving_rate >= 0.5:
        return 'sangat_optimal'
    if saving_rate >= 0.2:
        return 'optimal'
    if saving_rate >= 0:
        return 'cukup_optimal'
    return 'belum_optimal'


def upsert_cashflow_for_account(account, month, year):
    aggregates = Transaction.objects.filter(
        account_id=account,
        timestamp__year=year,
        timestamp__month=month,
    ).aggregate(
        total_income=Coalesce(
            Sum('amount', filter=Q(category_id__direction='income')),
            Value(0),
        ),
        total_expense=Coalesce(
            Sum('amount', filter=Q(category_id__direction='expense')),
            Value(0),
        ),
    )

    total_income = int(aggregates['total_income'] or 0)
    total_expense = int(aggregates['total_expense'] or 0)
    status_value = calculate_cashflow_status(total_income, total_expense)

    cashflow, _ = CashFlow.objects.update_or_create(
        account_id=account,
        month=month,
        year=year,
        defaults={
            'total_income': total_income,
            'total_expense': total_expense,
            'status': status_value,
        },
    )
    return cashflow


def upsert_cashflow_for_all_accounts(month, year):
    updated_count = 0
    for account in BankAccount.objects.all().iterator():
        upsert_cashflow_for_account(account=account, month=month, year=year)
        updated_count += 1
    return updated_count
