from django.db import migrations, models


CATEGORY_CHOICES = [
    ('transfer_in', 'Transfer In'),
    ('transfer_out', 'Transfer Out'),
    ('payment', 'Payment'),
    ('withdrawal', 'Withdrawal'),
    ('deposit', 'Deposit'),
    ('interest', 'Interest'),
    ('other', 'Other'),
]


def copy_category_from_fk(apps, schema_editor):
    Transaction = apps.get_model('banking', 'Transaction')
    TransactionCategory = apps.get_model('banking', 'TransactionCategory')

    category_lookup = {
        category['id']: category['category_name']
        for category in TransactionCategory.objects.values('id', 'category_name')
    }

    for transaction in Transaction.objects.all().iterator():
        transaction.category = category_lookup.get(transaction.category_id_id, 'other')
        transaction.save(update_fields=['category'])


class Migration(migrations.Migration):

    dependencies = [
        ('banking', '0006_saku_sakudetails_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='transaction',
            name='category',
            field=models.CharField(blank=True, choices=CATEGORY_CHOICES, max_length=50, null=True),
        ),
        migrations.RunPython(copy_category_from_fk, migrations.RunPython.noop),
        migrations.AlterField(
            model_name='transaction',
            name='category',
            field=models.CharField(choices=CATEGORY_CHOICES, max_length=50),
        ),
        migrations.RemoveField(
            model_name='transaction',
            name='category_id',
        ),
        migrations.DeleteModel(
            name='TransactionCategory',
        ),
    ]
