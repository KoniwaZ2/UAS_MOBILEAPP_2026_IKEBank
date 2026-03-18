from rest_framework import generics, permissions, status
from rest_framework.response import Response
from user.models import User, OtpVerification, generate_otp_code, hash_otp_code
from .serializers import (
    CheckPhoneEmailSerializer,
    RegisterSerializer,
    CustomTokenObtainPairSerializer,
    OtpRequestSerializer,
    OtpVerifySerializer,
    KtpUploadSerializer,
)
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model
from django.conf import settings

User = get_user_model()


def _mask_phone_number(phone_number):
    if not phone_number or len(phone_number) < 4:
        return phone_number
    return f"{phone_number[:4]}{'*' * max(len(phone_number) - 6, 1)}{phone_number[-2:]}"


def _mask_email(email):
    if not email or '@' not in email:
        return email
    local_part, domain = email.split('@', 1)
    if len(local_part) <= 2:
        return f"{local_part[0]}*@{domain}"
    masked_local = local_part[:2] + ('*' * (len(local_part) - 2))
    return f"{masked_local}@{domain}"


def _extract_identity_from_ktp_image(_ktp_image):
    # Placeholder extractor: replace this with OCR service integration.
    return {
        'name': '',
        'nik': '',
        'born_place': '',
        'born_date': '',
        'gender': '',
        'address': '',
        'religion': '',
        'mother_name': '',
    }


def _get_verified_registration_otp(reference, purpose):
    otp = OtpVerification.objects.filter(reference=reference, purpose=purpose).first()
    if otp is None:
        return None, Response({'detail': 'OTP reference not found.'}, status=status.HTTP_404_NOT_FOUND)
    if not otp.is_verified:
        return None, Response({'detail': 'OTP is not verified yet.'}, status=status.HTTP_400_BAD_REQUEST)
    return otp, None

class CheckPhoneEmailView(generics.GenericAPIView):
    serializer_class = CheckPhoneEmailSerializer
    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({"message": "Phone number and email are valid and available."}, status=200) 


class OtpRequestView(generics.GenericAPIView):
    serializer_class = OtpRequestSerializer
    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        otp_requests = []
        purpose = validated_data['purpose']

        if validated_data.get('email'):
            otp_code = generate_otp_code()
            otp = OtpVerification.objects.create(
                channel=OtpVerification.CHANNEL_EMAIL,
                destination=validated_data['email'],
                purpose=purpose,
                otp_code_hash=hash_otp_code(otp_code),
                expires_at=OtpVerification.get_default_expiry(minutes=5),
            )
            item = {
                'reference': str(otp.reference),
                'channel': otp.channel,
                'destination': _mask_email(otp.destination),
                'expires_at': otp.expires_at,
            }
            if settings.DEBUG:
                item['debug_otp_code'] = otp_code
            otp_requests.append(item)

        return Response(
            {
                'message': 'OTP generated successfully.',
                'purpose': purpose,
                'otp_requests': otp_requests,
            },
            status=status.HTTP_200_OK,
        )


class OtpVerifyView(generics.GenericAPIView):
    serializer_class = OtpVerifySerializer
    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        otp = OtpVerification.objects.filter(
            reference=validated_data['reference'],
            purpose=validated_data.get('purpose', OtpVerification.PURPOSE_REGISTRATION),
        ).first()

        if otp is None:
            return Response({'detail': 'OTP reference not found.'}, status=status.HTTP_404_NOT_FOUND)

        if otp.is_verified:
            return Response({'message': 'OTP already verified.', 'verified': True}, status=status.HTTP_200_OK)

        if otp.is_expired():
            return Response({'detail': 'OTP has expired.'}, status=status.HTTP_400_BAD_REQUEST)

        if otp.attempt_count >= otp.max_attempts:
            return Response({'detail': 'Maximum OTP attempts reached.'}, status=status.HTTP_400_BAD_REQUEST)

        verified = otp.verify_code(validated_data['otp_code'])
        if not verified:
            remaining_attempts = max(otp.max_attempts - otp.attempt_count, 0)
            return Response(
                {
                    'detail': 'Invalid OTP code.',
                    'remaining_attempts': remaining_attempts,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {
                'message': 'OTP verified successfully.',
                'verified': True,
                'reference': str(otp.reference),
                'channel': otp.channel,
                'purpose': otp.purpose,
            },
            status=status.HTTP_200_OK,
        )


class KtpUploadView(generics.GenericAPIView):
    serializer_class = KtpUploadSerializer
    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        otp, error_response = _get_verified_registration_otp(
            reference=validated_data['reference'],
            purpose=validated_data.get('purpose', OtpVerification.PURPOSE_REGISTRATION),
        )
        if error_response is not None:
            return error_response

        extracted_identity = _extract_identity_from_ktp_image(validated_data['ktp'])

        return Response(
            {
                'message': 'KTP uploaded and extracted successfully.',
                'reference': str(otp.reference),
                'prefill_identity': extracted_identity,
                'note': 'No identity data is stored until final register submission.',
            },
            status=status.HTTP_200_OK,
        )

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer