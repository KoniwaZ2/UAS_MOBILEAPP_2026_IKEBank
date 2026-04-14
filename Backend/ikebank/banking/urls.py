from django.urls import include, path

from .views import CashFlowCalculateView, RegisterBankAccountView, AccountDetailsView, TransactionCreateView, TambahDanaView, InternalTransferView, TambahSakuView, QrisCheckView, HistoryTransactionView, SakuView, SakuDetailView, TambahRekeningView, RekeningListView, CardDetailsView, CardRequestView, CardEditView, SavingsRecommendationView, NabungAIStateView, DepositoListView, DepositoEstimateView, DepositoCreateView, DepositoUserView, DepositoDetailsView, DepositoEditView, CardDailyLimitView, QrisDailyLimitView, ForgotPinView, BlockAccountView, CheckRekeningView


urlpatterns = [
    path ('register/', RegisterBankAccountView.as_view(), name='register-bank-account'),
    path ('account-details/', AccountDetailsView.as_view(), name='account-details'),
    path ('transactions/', TransactionCreateView.as_view(), name='transaction-create'),
	path('cashflow-calculate/', CashFlowCalculateView.as_view(), name='cashflow-calculate'),
    path('tambah-dana/', TambahDanaView.as_view(), name='tambah-dana'),
    path('internal-transfer/', InternalTransferView.as_view(), name='internal-transfer'),
    path('tambah-saku/', TambahSakuView.as_view(), name='tambah-saku'),
    path('saku-list/', SakuView.as_view(), name='saku-list-create'),
    path('savings-recommendation/', SavingsRecommendationView.as_view(), name='savings-recommendation'),
    path('nabung-ai-state/', NabungAIStateView.as_view(), name='nabung-ai-state'),
    path('saku-detail/', SakuDetailView.as_view(), name='saku-detail'),
    path('qris-check/', QrisCheckView.as_view(), name='qris-check'),
    path('qris-limit/', QrisDailyLimitView.as_view(), name='qris-limit'),
    path('transactions-history/', HistoryTransactionView.as_view(), name='transactions-history'),
    path('check-rekening', CheckRekeningView.as_view(), name='check-rekening'),
    path('tambah-rekening/', TambahRekeningView.as_view(), name='tambah-rekening'),
    path('rekening-list/', RekeningListView.as_view(), name='rekening-list'),
    path('card-request/', CardRequestView.as_view(), name='card-request'),
    path('card-details/', CardDetailsView.as_view(), name='card-details'),
    path('card-edit/', CardEditView.as_view(), name='card-edit'),
    path('deposito-list/', DepositoListView.as_view(), name='deposito-list'),
    path('deposito-estimate/', DepositoEstimateView.as_view(), name='deposito-estimate'),
    path('deposito-create/', DepositoCreateView.as_view(), name='deposito-create'),
    path('deposito-user/', DepositoUserView.as_view(), name='deposito-user'),
    path('deposito-details/', DepositoDetailsView.as_view(), name='deposito-details'),
    path('deposito-edit/', DepositoEditView.as_view(), name='deposito-edit'),
    path('daily-limit/', CardDailyLimitView.as_view(), name='card-daily-limit'),
    path('qris-daily-limit/', QrisDailyLimitView.as_view(), name='qris-daily-limit'),
    path('forgot-pin/', ForgotPinView.as_view(), name='forgot-pin'),
    path('block-account/', BlockAccountView.as_view(), name='block-account'),
]