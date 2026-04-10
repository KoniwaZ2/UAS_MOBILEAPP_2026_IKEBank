from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0016_fix_admin_log_user_fk'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='nabung_ai_auto_isi',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='user',
            name='nabung_ai_cooldown_until',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
