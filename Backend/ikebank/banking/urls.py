from django.urls import include, path

from .views import CashFlowCalculateView, RegisterBankAccountView, AccountDetailsView, TransactionCreateView


urlpatterns = [
    path ('register/', RegisterBankAccountView.as_view(), name='register-bank-account'),
    path ('account-details/', AccountDetailsView.as_view(), name='account-details'),
    path ('transactions/', TransactionCreateView.as_view(), name='transaction-create'),
	path('cashflow/calculate/', CashFlowCalculateView.as_view(), name='cashflow-calculate'),
]
