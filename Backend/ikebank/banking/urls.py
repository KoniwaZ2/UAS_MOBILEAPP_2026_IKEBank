from django.urls import include, path

from .views import CashFlowCalculateView, RegisterBankAccountView, AccountDetailsView, TransactionCreateView, TambahDanaView, InternalTransferView, TambahSakuView, QrisCheckView, HistoryTransactionView, SakuView, SakuDetailView


urlpatterns = [
    path ('register/', RegisterBankAccountView.as_view(), name='register-bank-account'),
    path ('account-details/', AccountDetailsView.as_view(), name='account-details'),
    path ('transactions/', TransactionCreateView.as_view(), name='transaction-create'),
	path('cashflow/calculate/', CashFlowCalculateView.as_view(), name='cashflow-calculate'),
    path('tambah-dana/', TambahDanaView.as_view(), name='tambah-dana'),
    path('internal-transfer/', InternalTransferView.as_view(), name='internal-transfer'),
    path('tambah-saku/', TambahSakuView.as_view(), name='tambah-saku'),
    path('saku-list/', SakuView.as_view(), name='saku-list-create'),
    path('saku-detail/', SakuDetailView.as_view(), name='saku-detail'),
    path('qris-check/', QrisCheckView.as_view(), name='qris-check'),
    path('transactions-history/', HistoryTransactionView.as_view(), name='transactions-history'),
]