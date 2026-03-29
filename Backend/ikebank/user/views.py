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
    FaceUploadSerializer,
    CheckLoginSerializer,
    OtpLoginSerializer,
)
from user.models import RegistrationDraft
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from django.conf import settings
from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives
import re
import pytesseract
from PIL import Image
import user.models as user_models

User = get_user_model()


# def _mask_phone_number(phone_number):
#     if not phone_number or len(phone_number) < 4:
#         return phone_number
#     return f"{phone_number[:4]}{'*' * max(len(phone_number) - 6, 1)}{phone_number[-2:]}"


def _mask_email(email):
    if not email or '@' not in email:
        return email
    local_part, domain = email.split('@', 1)
    if len(local_part) <= 2:
        return f"{local_part[0]}*@{domain}"
    masked_local = local_part[:2] + ('*' * (len(local_part) - 2))
    return f"{masked_local}@{domain}"


def _extract_identity_from_ktp_image(_ktp_image):
    def _extract_field_from_lines(lines, labels):
        for line in lines:
            normalized_line = re.sub(r'\s+', ' ', line).strip()
            upper_line = normalized_line.upper()
            for label in labels:
                if upper_line.startswith(label):
                    value = re.sub(r'^.*?:', '', normalized_line, count=1).strip()
                    if not value and ':' not in normalized_line:
                        value = normalized_line[len(label):].strip(' .:-')
                    return value
        return ''

    def _extract_nik(text):
        match = re.search(r'\b\d{16}\b', text)
        if match:
            return match.group(0)

        # Fallback for OCR output that inserts spaces between digits.
        compact_digits = re.sub(r'\D', '', text)
        fallback_match = re.search(r'\d{16}', compact_digits)
        return fallback_match.group(0) if fallback_match else ''

    try:
        _ktp_image.seek(0)
        image = Image.open(_ktp_image)
        raw_text = pytesseract.image_to_string(image, lang='ind')
    except Exception:
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

    lines = [line.strip() for line in raw_text.splitlines() if line.strip()]
    name = _extract_field_from_lines(lines, ['NAMA'])
    address = _extract_field_from_lines(lines, ['ALAMAT'])
    religion = _extract_field_from_lines(lines, ['AGAMA'])
    gender = _extract_field_from_lines(lines, ['JENIS KELAMIN'])

    born_place = ''
    born_date = ''
    birth_line = _extract_field_from_lines(lines, ['TEMPAT/TGL LAHIR', 'TEMPAT, TGL LAHIR'])
    if birth_line:
        # Common format: "KOTA, DD-MM-YYYY".
        parts = [item.strip() for item in birth_line.split(',') if item.strip()]
        if len(parts) >= 2:
            born_place = parts[0]
            born_date = parts[1]
        else:
            date_match = re.search(r'(\d{2}[-/]\d{2}[-/]\d{4})', birth_line)
            if date_match:
                born_date = date_match.group(1)
                born_place = birth_line.replace(born_date, '').strip(' ,.-')
            else:
                born_place = birth_line

    extracted = {
        'name': name,
        'nik': _extract_nik(raw_text),
        'born_place': born_place,
        'born_date': born_date,
        'gender': gender,
        'address': address,
        'religion': religion,
        # Not available on Indonesian KTP, kept for registration payload compatibility.
        'mother_name': '',
    }
    if settings.DEBUG:
        extracted['raw_text'] = raw_text

    return extracted


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

        # Handle phone_number (SMS) - TODO: Integrate SMS provider
        if validated_data.get('phone_number'):
            otp_code = generate_otp_code()
            otp = OtpVerification.objects.create(
                channel=OtpVerification.CHANNEL_SMS,
                destination=validated_data['phone_number'],
                purpose=purpose,
                otp_code_hash=hash_otp_code(otp_code),
                expires_at=OtpVerification.get_default_expiry(minutes=5),
            )
            
            # TODO: Send SMS to phone_number
            # sms_service.send_otp(validated_data['phone_number'], otp_code)
            
            item = {
                'reference': str(otp.reference),
                'channel': otp.channel,
                'destination': validated_data['phone_number'][-4:].rjust(len(validated_data['phone_number']), '*'),
                'expires_at': otp.expires_at,
            }
            if settings.DEBUG:
                item['debug_otp_code'] = otp_code
            otp_requests.append(item)

        # Handle email
        if validated_data.get('email'):
            otp_code = generate_otp_code()
            otp = OtpVerification.objects.create(
                channel=OtpVerification.CHANNEL_EMAIL,
                destination=validated_data['email'],
                purpose=purpose,
                otp_code_hash=hash_otp_code(otp_code),
                expires_at=OtpVerification.get_default_expiry(minutes=5),
            )
            
            html_content = render_to_string('email/otp.html', {
                'otp': otp_code,
                'purpose': purpose,
            })
            
            message = EmailMultiAlternatives(
                subject='Kode OTP Kamu',
                body='Gunakan kode OTP kamu',
                from_email='noreply@ikebank.com',
                to=[validated_data['email']],
            )

            message.attach_alternative(html_content, "text/html")
            message.send()

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
            return Response(
                {'detail': 'OTP already verified. Please request a new OTP code.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

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


class FaceUploadView(generics.GenericAPIView):
    serializer_class = FaceUploadSerializer
    permission_classes = (permissions.AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        purpose = validated_data.get('purpose', OtpVerification.PURPOSE_REGISTRATION)

        if purpose == OtpVerification.PURPOSE_REGISTRATION:
            reference = validated_data.get('reference')
            if reference is None:
                return Response(
                    {'detail': 'reference is required for registration face upload.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            otp, error_response = _get_verified_registration_otp(
                reference=reference,
                purpose=OtpVerification.PURPOSE_REGISTRATION,
            )
            if error_response is not None:
                return error_response

            draft, _ = RegistrationDraft.objects.get_or_create(otp_reference=otp)
            draft.face_image = validated_data['face']
            draft.save(update_fields=['face_image', 'updated_at'])

            return Response(
                {
                    'message': 'Face image uploaded successfully.',
                    'reference': str(otp.reference),
                    'purpose': purpose,
                },
                status=status.HTTP_200_OK,
            )

        return Response(
            {
                'message': 'Face image uploaded successfully.',
                'purpose': purpose,
            },
            status=status.HTTP_200_OK,
        )

class CheckLoginView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = CheckLoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone_number = serializer.validated_data.get('phone_number')
        email = serializer.validated_data.get('email')

        if not phone_number and not email:
            return Response({'detail': 'Either phone number or email is required.'}, status=status.HTTP_400_BAD_REQUEST)

        user_exists = User.objects.filter(phone_number=phone_number).exists() if phone_number else User.objects.filter(email=email).exists()

        if user_exists:
            return Response({'exists': True, 'message': 'User with this phone number exists.'}, status=status.HTTP_200_OK)
        else:
            return Response({'exists': False, 'message': 'No user found with this phone number.'}, status=status.HTTP_200_OK)

class OtpLoginView(generics.GenericAPIView):
    """
    Login using verified OTP + password
    Flow: 
    1. User checks login with /api/auth/login-check/
    2. User requests OTP with /api/auth/otp/request/ (purpose='login')
    3. User verifies OTP with /api/auth/otp/verify/ (purpose='login')
    4. User does facial recognition [TODO]
    5. User calls this endpoint with otp_reference + password
    """
    permission_classes = (permissions.AllowAny,)
    serializer_class = OtpLoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated_data = serializer.validated_data

        user = validated_data['user']

        # Generate tokens
        refresh = RefreshToken.from_user(user)
        
        # Add custom claims to refresh token
        refresh['phone_number'] = user.phone_number
        refresh['email'] = user.email
        refresh['name'] = user.name
        
        return Response({
            'message': 'Login successful.',
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'phone_number': user.phone_number,
                'email': user.email,
                'name': user.name,
                'biometric_data': getattr(user, 'biometric_data', None),
            }
        }, status=status.HTTP_200_OK)

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer