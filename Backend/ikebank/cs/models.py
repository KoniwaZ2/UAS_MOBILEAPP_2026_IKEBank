from django.db import models
from banking.models import BankAccount
from user.models import User

class Chat(models.Model):
    user = models.ForeignKey('user.User', on_delete=models.CASCADE, related_name='chats')
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.name} - {self.message[:20]}..."