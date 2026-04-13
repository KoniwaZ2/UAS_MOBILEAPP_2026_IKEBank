from django.contrib import admin
from .models import ChatSession, ChatMessage

@admin.register(ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ('id', 'user_id', 'intent', 'status')
    list_filter = ('status',)
    search_fields = ('user_id', 'intent')

@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ('id', 'session', 'sender', 'message', 'timestamp')
    list_filter = ('sender',)
    search_fields = ('message',)