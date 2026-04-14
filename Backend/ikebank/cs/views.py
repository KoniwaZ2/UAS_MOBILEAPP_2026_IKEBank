from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view
from rest_framework.response import Response
from banking.models import BankAccount
from .service import get_intent
from rest_framework import generics, permissions, status
from .serializers import FaceVerificationSerializer, ReportSerializer
from .models import ChatSession, ChatMessage, Report

def get_user_bank_account(user):
    return BankAccount.objects.filter(user=user).first()

# Endpoint untuk menandai sesi chat selesai (misal user tekan tombol x)
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def close_chat_session(request):
    user = request.user
    session = ChatSession.objects.filter(user_id=user.id, status="ONGOING").first()
    if session:
        session.status = "DONE"
        session.save()
        return Response({"detail": "Chat session closed."}, status=200)
    return Response({"detail": "No active chat session found."}, status=404)

@api_view(['POST'])
def send_message(request):
    user = request.user if request.user.is_authenticated else None
    message = request.data.get("message")

    # Ambil atau buat session chat untuk user ini
    session = None
    if user:
        session, _ = ChatSession.objects.get_or_create(user_id=user.id, status="ONGOING")
    else:
        # Untuk user anonymous, bisa pakai session key
        session, _ = ChatSession.objects.get_or_create(user_id=0, status="ONGOING")

    # cek apakah masih ada case aktif
    if request.session.get("status") == "ONGOING":
        # Simpan pesan user
        ChatMessage.objects.create(session=session, sender="user", message=message)
        return Response({
            "message": "Selesaikan proses sebelumnya dulu",
        })

    intent = get_intent(message)

    # Simpan pesan user
    ChatMessage.objects.create(session=session, sender="user", message=message)

    # Update session intent & status
    session.intent = intent
    session.status = "ONGOING"
    session.save()

    # Simpan pesan AI
    ai_message = "Silakan verifikasi wajah"
    ChatMessage.objects.create(session=session, sender="bot", message=ai_message)

    request.session['intent'] = intent
    request.session['status'] = "ONGOING"

    if intent == "OTHER":
        # Jika intent tidak dikenali, langsung tandai session selesai
        session.status = "DONE"
        session.save()
        request.session['status'] = "IDLE"
        return Response({
            "message": "Maaf, saya tidak mengerti. Bisa coba jelaskan dengan cara lain?",
            "action": None,
            "timestamp": session.messages.last().timestamp,
        })

    return Response({
        "message": ai_message,
        "action": "FACE_VERIFICATION",
        "timestamp": session.messages.last().timestamp,
        "intent": intent,
    })

class FaceVerificationView(generics.GenericAPIView):
    serializer_class = FaceVerificationSerializer
    permission_classes = [permissions.IsAuthenticated]  # Ensure user is authenticated to access this view

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = get_user_bank_account(request.user)

        if not account.face_encoding and not account.face_image:
            return Response(
                {'detail': 'User has no registered face data. Please complete registration first.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        probe_encoding = user_models.extract_face_encoding(validated_data['face'])
        if not probe_encoding:
            return Response({'detail': 'Failed to extract face features from uploaded image.'}, status=status.HTTP_400_BAD_REQUEST)

        # Prefer recomputing encoding from persisted face image to avoid stale/legacy vectors.
        stored_encoding = None
        if account.face_image:
            stored_encoding = user_models.extract_face_encoding(account.face_image)

        if not stored_encoding:
            stored_encoding = account.face_encoding

        if not stored_encoding:
            return Response(
                {'detail': 'Stored face data is missing. Please re-register face data.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if len(stored_encoding) != len(probe_encoding):
            return Response({'detail': 'Stored face data is invalid. Please re-register face data.'}, status=status.HTTP_400_BAD_REQUEST)

        stored_vector = [float(v) for v in stored_encoding]
        probe_vector = [float(v) for v in probe_encoding]

        # RMS distance catches absolute per-dimension gaps.
        squared_sum = sum((a - b) ** 2 for a, b in zip(stored_vector, probe_vector))
        rms_distance = math.sqrt(squared_sum / len(stored_vector))

        # Cosine similarity helps stabilize against brightness/contrast differences.
        dot_product = sum(a * b for a, b in zip(stored_vector, probe_vector))
        stored_norm = math.sqrt(sum(a * a for a in stored_vector))
        probe_norm = math.sqrt(sum(b * b for b in probe_vector))
        if stored_norm == 0 or probe_norm == 0:
            return Response({'detail': 'Face vector is invalid. Please re-register face data.'}, status=status.HTTP_400_BAD_REQUEST)

        cosine_similarity = dot_product / (stored_norm * probe_norm)

        max_rms_distance = float(getattr(settings, 'FACE_LOGIN_MAX_RMS_DISTANCE', 0.08))
        min_cosine_similarity = float(getattr(settings, 'FACE_LOGIN_MIN_COSINE_SIMILARITY', 0.985))
        is_match = rms_distance <= max_rms_distance and cosine_similarity >= min_cosine_similarity

        if not is_match:
            return Response(
                {
                    'verified': False,
                    'detail': 'Face does not match.',
                    'distance': round(rms_distance, 6),
                    'cosine_similarity': round(cosine_similarity, 6),
                    'max_rms_distance': max_rms_distance,
                    'min_cosine_similarity': min_cosine_similarity,
                },
                status=status.HTTP_401_UNAUTHORIZED,
            )

        return Response(
            {
                'message': 'Face verified successfully.',
                'verified': True,
                'user': {
                    'phone_number': account.user.phone_number,
                    'email': account.user.email,
                    'name': account.user.name,
                },
                'distance': round(rms_distance, 6),
                'cosine_similarity': round(cosine_similarity, 6),
                'max_rms_distance': max_rms_distance,
                'min_cosine_similarity': min_cosine_similarity,
            },
            status=status.HTTP_200_OK,
        )

class ReportView(generics.GenericAPIView):
    serializer_class = ReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        account = BankAccount.objects.filter(user=request.user).first()
        if not account:
            return Response({'detail': 'Bank account not found for this user.'}, status=status.HTTP_404_NOT_FOUND)

        latest_session = ChatSession.objects.filter(user_id=request.user.id).order_by('-id').first()
        description = latest_session.intent if latest_session and latest_session.intent else "No active session"
        report = Report.objects.create(
            report_number=validated_data['report_number'],
            user=request.user,
            account=account,
            description=description
        )

        if description == "HACK_ACCOUNT":
            account.block = True
            account.save()

        return Response({'detail': 'Report submitted successfully.', 'report_number': report.report_number}, status=status.HTTP_200_OK)