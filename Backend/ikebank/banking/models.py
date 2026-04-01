from django.db import models

#semua saldo termasuk dari deposito, saku, dan tabungan
class BankAccount(models.Model):
    user = models.ForeignKey('user.User', on_delete=models.CASCADE, related_name='bank_accounts')
    account_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    card_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    balance = models.IntegerField(default=0)
    block = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.name} - {self.account_number}"
    

class TransactionCategory(models.Model):
    CATEGORY_CHOICES = [
        ('transfer_in', 'Transfer In'),
        ('transfer_out', 'Transfer Out'),
        ('payment', 'Payment'),
        ('withdrawal', 'Withdrawal'),
        ('deposit', 'Deposit'),
        ('interest', 'Interest'),
        ('other', 'Other'),
    ]

    DIRECTION_CHOICES = [
        ('income', 'Income'),
        ('expense', 'Expense'),
    ]

    category_name = models.CharField(max_length=50, unique=True, null=False, blank=False, choices=CATEGORY_CHOICES)
    direction = models.CharField(max_length=10, choices=DIRECTION_CHOICES, null=False, blank=False)

    def __str__(self):
        return self.category_name
    
class Transaction(models.Model):
    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='transactions')
    saku = models.ForeignKey('Saku', on_delete=models.CASCADE, null=True, blank=True, related_name='transactions')
    category_id = models.ForeignKey(TransactionCategory, on_delete=models.SET_NULL, null=True, related_name='transactions')
    amount = models.IntegerField(null=False, blank=False)
    balance_after = models.IntegerField(null=False, blank=False)
    timestamp = models.DateTimeField(auto_now_add=True)
    description = models.TextField(blank=True, null=True)
    source_funds = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return f"{self.saku.saku_name if self.saku else 'No Saku'} - {self.category_id} - {self.amount}"
    
class CashFlow(models.Model):
    STATUS_CHOICES = [
        ('sangat_optimal', 'Sangat Optimal'),
        ('optimal', 'Optimal'),
        ('cukup_optimal', 'Cukup Optimal'),
        ('belum_optimal', 'Belum Optimal'),
    ]

    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='cash_flows')
    total_income = models.IntegerField(default=0)
    total_expense = models.IntegerField(default=0)
    month = models.IntegerField()
    year = models.IntegerField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['account_id', 'month', 'year'],
                name='unique_cashflow_per_account_month_year'
            ),
        ]


class Qris(models.Model):
    qris_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    merchant_name = models.CharField(max_length=255, null=False, blank=False)

    def __str__(self):
        return f"{self.merchant_name} - {self.qris_number}"
    
class CardDetails(models.Model):
    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='card_details')
    cardholder_name = models.CharField(max_length=255, null=False, blank=False)
    pin = models.CharField(max_length=6, null=False, blank=False)
    ccv = models.CharField(max_length=4, null=False, blank=False)
    block_permanent = models.BooleanField(default=False)
    block_temporary = models.BooleanField(default=False)
    daily_transaction_limit = models.IntegerField(default=100000000)
    daily_single_transaction_limit = models.IntegerField(default=50000000)
    daily_withdrawal_limit = models.IntegerField(default=15000000)
    expiry_date = models.DateField(null=False, blank=False)

    def __str__(self):
        return f"{self.cardholder_name} - {self.card_number}"

class Saku(models.Model):
    CATEGORY_CHOICES = [
        ("Nabung", "Nabung"),
        ("Transaksi", "Transaksi"),
        ("Lainnya", "Lainnya"),
    ]
    id = models.BigAutoField(primary_key=True)
    saku_name = models.CharField(max_length=50, null=False, blank=False)
    account = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='sakus')
    category_name = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    balance = models.IntegerField(default=0)
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.saku_name

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['account'],
                condition=models.Q(is_primary=True),
                name='unique_primary_saku_per_account'
            ),
        ]

class SakuDetails(models.Model):
    saku = models.ForeignKey(Saku, on_delete=models.CASCADE, related_name='details')
    name = models.CharField(max_length=100, blank=False)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.saku.saku_name} - {self.name}"
