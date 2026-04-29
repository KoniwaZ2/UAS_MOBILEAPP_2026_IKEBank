from django.db import models
from banking.models import BankAccount
from user.models import User
from django.utils import timezone
from django.db import transaction

class ChatSession(models.Model):
    STATUS_CHOICES = [
        ("IDLE", "idle"),
        ("ONGOING", "ongoing"),
        ("DONE", "done"),
    ]

    user_id = models.IntegerField()
    intent = models.CharField(max_length=50, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="IDLE")

class ChatMessage(models.Model):
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name="messages")
    sender = models.CharField()  # user / bot
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

class Report(models.Model):
    DESCRIPTION_CHOICES = [
        ('HACKING', 'hacking'),
        ('PIN', 'pin')
    ]
    report_number = models.CharField(max_length=20, unique=True, blank=True, primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    account = models.ForeignKey(BankAccount, on_delete=models.CASCADE)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.report_number:
            today = timezone.now().strftime('%Y%m%d')
            # Lock to avoid race condition
            with transaction.atomic():
                last = Report.objects.filter(report_number__startswith=f'RPT{today}').order_by('-report_number').first()
                if last and last.report_number[11:].isdigit():
                    seq = int(last.report_number[11:]) + 1
                else:
                    seq = 1
                self.report_number = f'RPT{today}{seq:04d}'
        super().save(*args, **kwargs)