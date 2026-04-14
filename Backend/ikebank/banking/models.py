from django.db import models
import uuid
#semua saldo termasuk dari deposito, saku, dan tabungan
class BankAccount(models.Model):
    user = models.ForeignKey('user.User', on_delete=models.CASCADE, related_name='bank_accounts')
    account_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    card_number = models.CharField(max_length=20, unique=False, null=False, blank=True)
    balance = models.IntegerField(default=0)
    block = models.BooleanField(default=False)
    qris_limit = models.IntegerField(default=10000000)
    block = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.name} - {self.account_number}"


class Transaction(models.Model):
    CATEGORY_CHOICES = [
        ('transfer_in', 'Transfer In'),
        ('transfer_out', 'Transfer Out'),
        ('payment', 'Payment'),
        ('withdrawal', 'Withdrawal'),
        ('deposit', 'Deposit'),
        ('interest', 'Interest'),
        ('other', 'Other'),
    ]

    INCOME_CATEGORIES = ('transfer_in', 'deposit', 'interest')
    EXPENSE_CATEGORIES = ('transfer_out', 'payment', 'withdrawal', 'other')
    
    transaction_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='transactions')
    saku = models.ForeignKey('Saku', on_delete=models.CASCADE, null=True, blank=True, related_name='transactions')
    qris = models.ForeignKey('Qris', on_delete=models.SET_NULL, null=True, blank=True, related_name='transactions')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, null=False, blank=False)
    amount = models.IntegerField(null=False, blank=False)
    balance_after = models.IntegerField(null=False, blank=False)
    timestamp = models.DateTimeField(auto_now_add=True)
    description = models.TextField(blank=True, null=True)
    source_funds = models.CharField(max_length=255, blank=True, null=True)
    merchant_name_snapshot = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return f"{self.saku.saku_name if self.saku else 'No Saku'} - {self.category} - {self.amount}"
    
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
    AQUIERER_CHOICES = [
        ('Bank BCA', 'Bank BCA'),
    ]
    qris_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    merchant_name = models.CharField(max_length=255, null=False, blank=False)
    location = models.CharField(max_length=255, null=True, blank=True)
    aquirer = models.CharField(max_length=255, null=True, blank=True, choices=AQUIERER_CHOICES)
    PAN_id = models.CharField(max_length=20, unique=True, null=True, blank=True)

    def __str__(self):
        return f"{self.merchant_name} - {self.qris_number}"
    
class CardDetails(models.Model):
    CARD_STATUS_CHOICES = [
        ('active', 'Active'),
        ('blocked', 'Blocked'),
        ('requested', 'Requested'),
        ('blocked_temporary', 'Blocked Temporary'),
        ('none', 'None'),
    ]
    account = models.ForeignKey(
        BankAccount,
        on_delete=models.CASCADE,
        related_name='card_details_history',
        null=True,
        blank=True,
    )
    card_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    cardholder_name = models.CharField(max_length=255, null=False, blank=False)
    source_funds_id = models.CharField(max_length=255, blank=True, null=True) #id sumber dana user
    pin = models.CharField(max_length=6, null=False, blank=False)
    ccv = models.CharField(max_length=4, null=False, blank=False)
    block_permanent = models.BooleanField(default=False)
    block_temporary = models.BooleanField(default=False)
    daily_transaction_limit = models.IntegerField(default=100000000)
    daily_single_transaction_limit = models.IntegerField(default=50000000)
    daily_withdrawal_limit = models.IntegerField(default=15000000)
    card_status = models.CharField(max_length=20, choices=CARD_STATUS_CHOICES, default='none')
    expiry_date = models.DateField(null=False, blank=False)
    added_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.cardholder_name} - {self.card_number}"

class Saku(models.Model):
    CATEGORY_CHOICES = [
        ("utama", "Utama"),
        ("nabung", "Nabung"),
        ("transaksi", "Transaksi"),
        ("celengan", "Celengan"),
        ("lainnya", "Lainnya"),
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

class Beneficiaries(models.Model):
    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='beneficiaries') #pemilik daftar
    destination_account = models.ForeignKey(
        BankAccount,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='as_beneficiary_destination',
    )
    account_number = models.CharField(max_length=20, null=False, blank=False) #nomor rekening tujuan
    bank_name = models.CharField(max_length=255, null=False, blank=False, default='IKE Bank')
    account_holder_name = models.CharField(max_length=255, null=True, blank=True) #nama pemilik rekening tujuan
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['account_id', 'account_number'],
                name='unique_beneficiary_per_account_number',
            ),
        ]
        indexes = [
            models.Index(fields=['account_id', 'added_at']),
        ]

    def save(self, *args, **kwargs):
        normalized_number = (self.account_number or '').strip()
        self.account_number = normalized_number

        linked_destination = BankAccount.objects.filter(
            account_number=normalized_number,
        ).first()

        self.destination_account = linked_destination

        if linked_destination is not None:
            self.bank_name = 'IKE Bank'
            if not self.account_holder_name:
                self.account_holder_name = linked_destination.user.name

        super().save(*args, **kwargs)

    def __str__(self):
        return self.account_holder_name or f"Beneficiary {self.account_id.id}"
    
class Deposito(models.Model): #list deposito yang tersedia untuk dipilih oleh user saat membuat deposito baru
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
    ]
    deposito_id = models.IntegerField(primary_key=True, auto_created=True)
    interest_rate = models.FloatField(null=False, blank=False)
    quota = models.IntegerField(null=True, blank=True)
    duratuion_months = models.IntegerField(null=False, blank=False)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    isSpecial = models.BooleanField(default=False) #untuk menandai apakah deposito ini adalah deposito khusus dengan syarat tertentu, misalnya hanya untuk nasabah dengan saldo tertentu, atau hanya untuk nasabah yang sudah memiliki deposito sebelumnya

class DepositoAccount(models.Model): #setiap deposito yang dibuat oleh user akan masuk ke tabel ini, dan akan terhubung dengan bank account yang dimiliki user
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('withdrawn', 'Withdrawn'),
    ]
    deposito_account_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    deposito_id = models.ForeignKey(Deposito, on_delete=models.CASCADE, related_name='user_depositos', default=1)
    account_id = models.ForeignKey(BankAccount, on_delete=models.CASCADE, related_name='account_depositos')
    balance = models.IntegerField(default=0)
    start_date = models.DateField(null=False, blank=False)
    end_date = models.DateField(null=False, blank=False)
    deposito_name = models.CharField(max_length=255, null=False, blank=False)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active') #active, withdrawn

class CardBlacklist(models.Model):
    card_number = models.CharField(max_length=20, unique=True, null=False, blank=False)
    reason = models.TextField(blank=True, null=True)
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.card_number