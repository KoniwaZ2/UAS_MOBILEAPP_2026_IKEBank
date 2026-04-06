from datetime import timedelta

from django.db.models import Q, Sum, Value
from django.db.models.functions import Coalesce
from django.utils import timezone

from .models import BankAccount, CashFlow, Saku, Transaction


SAVINGS_RECOMMENDATION_TIERS = (
    {
        'code': 'BAL_0_500K',
        'balance_min': 0,
        'balance_max': 500000,
        'min_transactions': 0,
        'recommend_min': 1000,
        'recommend_max': 50000,
    },
    {
        'code': 'BAL_500K_2M_TX_5',
        'balance_min': 500000,
        'balance_max': 2000000,
        'min_transactions': 5,
        'recommend_min': 50000,
        'recommend_max': 100000,
    },
    {
        'code': 'BAL_2M_10M_TX_10',
        'balance_min': 2000000,
        'balance_max': 10000000,
        'min_transactions': 10,
        'recommend_min': 100000,
        'recommend_max': 300000,
    },
    {
        'code': 'BAL_ABOVE_10M_TX_15',
        'balance_min': 10000000,
        'balance_max': None,
        'min_transactions': 15,
        'recommend_min': 300000,
        'recommend_max': 500000,
    },
)


def _clamp(value, lower, upper):
    return max(lower, min(value, upper))


def _round_to_nearest_thousand(amount):
    return int(round(amount / 1000.0) * 1000)


def _select_recommendation_tier(primary_balance, weekly_transaction_count):
    # First pass: strict balance-range + min transaction rule.
    for tier in reversed(SAVINGS_RECOMMENDATION_TIERS):
        balance_max = tier['balance_max']
        in_range = primary_balance >= tier['balance_min']
        if balance_max is not None:
            in_range = in_range and primary_balance < balance_max

        if in_range and weekly_transaction_count >= tier['min_transactions']:
            return tier

    # Fallback: allow dropping to a lower tier when transaction requirement is unmet.
    for tier in reversed(SAVINGS_RECOMMENDATION_TIERS):
        if primary_balance >= tier['balance_min'] and weekly_transaction_count >= tier['min_transactions']:
            return tier

    return SAVINGS_RECOMMENDATION_TIERS[0]


def _calculate_recommended_amount(tier, primary_balance, weekly_transaction_count):
    minimum = tier['recommend_min']
    maximum = tier['recommend_max']
    min_balance = tier['balance_min']
    max_balance = tier['balance_max']
    min_transactions = tier['min_transactions']

    if max_balance is None or max_balance <= min_balance:
        balance_ratio = 1.0 if primary_balance >= min_balance else 0.0
    else:
        balance_ratio = (primary_balance - min_balance) / float(max_balance - min_balance)
        balance_ratio = _clamp(balance_ratio, 0.0, 1.0)

    if min_transactions <= 0:
        blended_ratio = balance_ratio
    else:
        transaction_ratio = _clamp(weekly_transaction_count / float(min_transactions), 0.0, 1.0)
        blended_ratio = (balance_ratio + transaction_ratio) / 2.0

    amount = minimum + ((maximum - minimum) * blended_ratio)
    rounded = _round_to_nearest_thousand(amount)
    return _clamp(rounded, minimum, maximum)


def get_weekly_savings_recommendation(account):
    if account is None:
        raise ValueError('Account is required.')

    primary_saku = Saku.objects.filter(account=account, is_primary=True).first()
    primary_balance = int(primary_saku.balance if primary_saku is not None else 0)

    period_end = timezone.now()
    period_start = period_end - timedelta(days=7)

    weekly_transaction_count = Transaction.objects.filter(
        account_id=account,
        category='payment',
        timestamp__gte=period_start,
        timestamp__lte=period_end,
    ).count()

    selected_tier = _select_recommendation_tier(
        primary_balance=primary_balance,
        weekly_transaction_count=weekly_transaction_count,
    )

    recommended_amount = _calculate_recommended_amount(
        tier=selected_tier,
        primary_balance=primary_balance,
        weekly_transaction_count=weekly_transaction_count,
    )

    return {
        'primary_saku_balance': primary_balance,
        'weekly_transaction_count': weekly_transaction_count,
        'tier': selected_tier['code'],
        'range_min': selected_tier['recommend_min'],
        'range_max': selected_tier['recommend_max'],
        'recommended_amount': int(recommended_amount),
        'period_start': period_start.date().isoformat(),
        'period_end': period_end.date().isoformat(),
    }


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
            Sum('amount', filter=Q(category__in=Transaction.INCOME_CATEGORIES)),
            Value(0),
        ),
        total_expense=Coalesce(
            Sum('amount', filter=Q(category__in=Transaction.EXPENSE_CATEGORIES)),
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
