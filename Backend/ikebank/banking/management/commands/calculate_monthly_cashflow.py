from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from banking.services import upsert_cashflow_for_all_accounts


class Command(BaseCommand):
    help = 'Calculate monthly cashflow for all accounts based on Transaction data.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--month',
            type=int,
            help='Target month (1-12). Defaults to previous month.',
        )
        parser.add_argument(
            '--year',
            type=int,
            help='Target year (e.g. 2026). Defaults to previous month year.',
        )

    def handle(self, *args, **options):
        month = options.get('month')
        year = options.get('year')

        if (month is None) != (year is None):
            self.stderr.write(self.style.ERROR('Please provide both --month and --year, or neither.'))
            return

        if month is None and year is None:
            today = timezone.localdate()
            prev_month_date = today.replace(day=1) - timedelta(days=1)
            month = prev_month_date.month
            year = prev_month_date.year

        if month < 1 or month > 12:
            self.stderr.write(self.style.ERROR('Month must be between 1 and 12.'))
            return

        updated_count = upsert_cashflow_for_all_accounts(month=month, year=year)
        self.stdout.write(
            self.style.SUCCESS(
                f'Cashflow updated for {updated_count} accounts for {month:02d}/{year}.'
            )
        )
