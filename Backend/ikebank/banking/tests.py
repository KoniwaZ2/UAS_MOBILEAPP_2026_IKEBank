from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from user.models import User, hash_pin

from .models import BankAccount, Qris, Saku, Transaction


class QrisLimitTests(APITestCase):
	def setUp(self):
		self.user = User.objects.create_user(
			phone_number='081234567890',
			email='user@example.com',
			password='password123',
			name='User Test',
			born_place='Jakarta',
			born_date='1995-01-01',
			gender='MALE',
			address='Jl. Test',
			religion='ISLAM',
			mother_name='Ibu Test',
			pin=hash_pin('123456'),
		)
		self.account = BankAccount.objects.create(
			user=self.user,
			account_number='100000000001',
			card_number='',
			balance=500000,
			qris_limit=1000,
		)
		self.primary_saku = Saku.objects.create(
			saku_name='Saku Utama',
			account=self.account,
			category_name='nabung',
			balance=500000,
			is_primary=True,
		)
		self.qris = Qris.objects.create(
			qris_number='QRIS001',
			merchant_name='Merchant Test',
		)
		self.client.force_authenticate(user=self.user)

	def test_qris_daily_limit_can_be_updated(self):
		response = self.client.patch(
			reverse('qris-limit'),
			{'qris_limit': 2500},
			format='json',
		)

		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.account.refresh_from_db()
		self.assertEqual(self.account.qris_limit, 2500)
		self.assertEqual(response.data['qris_limit'], 2500)

	def test_qris_transaction_is_rejected_when_daily_limit_is_exceeded(self):
		Transaction.objects.create(
			account_id=self.account,
			saku=self.primary_saku,
			qris=self.qris,
			category='payment',
			amount=800,
			balance_after=499200,
			description='Existing QRIS payment',
			source_funds=self.qris.merchant_name,
			merchant_name_snapshot=self.qris.merchant_name,
		)

		response = self.client.post(
			reverse('transaction-create'),
			{
				'pin': '123456',
				'category': 'payment',
				'amount': 300,
				'merchant_qris': self.qris.qris_number,
				'description': 'Pembayaran QRIS',
			},
			format='json',
		)

		self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
		self.assertEqual(response.data['detail'], 'QRIS daily limit exceeded.')
		self.assertEqual(Transaction.objects.filter(category='payment', qris=self.qris).count(), 1)
