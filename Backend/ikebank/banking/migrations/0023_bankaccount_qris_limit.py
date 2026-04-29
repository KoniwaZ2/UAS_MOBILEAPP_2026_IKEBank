from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('banking', '0022_alter_carddetails_card_status'),
    ]

    operations = [
        migrations.AddField(
            model_name='bankaccount',
            name='qris_limit',
            field=models.IntegerField(default=10000000),
        ),
    ]
