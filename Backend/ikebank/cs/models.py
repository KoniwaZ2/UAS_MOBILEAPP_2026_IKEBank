from django.db import models
from banking.models import BankAccount
from user.models import User

class ChatSession(models.Model):
    STATUS_CHOICES = [
        ("IDLE", "Idle"),
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