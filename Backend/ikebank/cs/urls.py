from django.urls import path

from .views import send_message, FaceVerificationView, close_chat_session, ReportView

urlpatterns = [
    path('chat/message/', send_message, name='send_message'),
    path('face-verification/', FaceVerificationView.as_view(), name='face_verification'),
    path('chat/close/', close_chat_session, name='close_chat_session'),
    path('report/', ReportView.as_view(), name='report_issue'),
]