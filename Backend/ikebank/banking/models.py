from django.db import models

class BankAccount(models.Model):
    user = models.ForeignKey('user.User', on_delete=models.CASCADE, related_name='bank_accounts')
    account_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    card_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
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
    category_id = models.ForeignKey(TransactionCategory, on_delete=models.SET_NULL, null=True, related_name='transactions')
    amount = models.DecimalField(max_digits=12, decimal_places=2, null=False, blank=False)
    balance_after = models.DecimalField(max_digits=12, decimal_places=2, null=False, blank=False)
    timestamp = models.DateTimeField(auto_now_add=True)
    description = models.TextField(blank=True, null=True)
    source_funds = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return f"{self.category_id} - {self.amount} - {self.timestamp}"
    
class CashFlow(models.Model):
    STATUS_CHOICES = [
        ('sangat_optimal', 'Sangat Optimal'),
        ('optimal', 'Optimal'),
        ('cukup_optimal', 'Cukup Optimal'),
        ('belum_optimal', 'Belum Optimal'),
    ]

    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='cash_flows')
    total_income = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    total_expense = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    month = models.IntegerField()
    year = models.IntegerField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)


class Qris(models.Model):
    qris_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    merchant_name = models.CharField(max_length=255, null=False, blank=False)

    def __str__(self):
        return f"{self.merchant_name} - {self.qris_number}"