from django.urls import path
from .views import (
    RegisterView,
    CustomTokenObtainPairView,
    CheckPhoneEmailView,
    OtpRequestView,
    OtpVerifyView,
    KtpUploadView,
)
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('check/', CheckPhoneEmailView.as_view(), name='check-phone-email'),
    path('otp/request/', OtpRequestView.as_view(), name='otp-request'),
    path('otp/verify/', OtpVerifyView.as_view(), name='otp-verify'),
    path('ktp/upload/', KtpUploadView.as_view(), name='ktp-upload'),
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', CustomTokenObtainPairView.as_view(), name='logout'),
]

