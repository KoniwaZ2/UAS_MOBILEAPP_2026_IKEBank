from django.contrib import admin
from django.contrib.admin.forms import AdminAuthenticationForm
from django.core.exceptions import ValidationError
from .models import User


class SuperuserAdminAuthenticationForm(AdminAuthenticationForm):
    def confirm_login_allowed(self, user):
        if not user.is_active:
            raise ValidationError(
                self.error_messages['inactive'],
                code='inactive',
            )
        if not user.is_superuser:
            raise ValidationError(
                "Akun ini tidak memiliki akses admin.",
                code='not_superuser',
            )


admin.site.login_form = SuperuserAdminAuthenticationForm

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('phone_number', 'email', 'name', 'born_place', 'born_date', 'gender', 'address', 'religion', 'created_at', 'updated_at')
    search_fields = ('phone_number', 'email', 'name', 'nik')
    list_filter = ('gender', 'religion', 'created_at')
    exclude = ('groups', 'user_permissions')

    def log_addition(self, request, obj, message):
        return

    def log_change(self, request, obj, message):
        return

    def log_deletion(self, request, obj, object_repr):
        return

    def log_deletions(self, request, queryset):
        return
    
