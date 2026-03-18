from django.urls import path

from .views import CashFlowCalculateView, RegisterBankAccountView


urlpatterns = [
    path ('register/', RegisterBankAccountView.as_view(), name='register-bank-account'),
	path('cashflow/calculate/', CashFlowCalculateView.as_view(), name='cashflow-calculate'),
]
