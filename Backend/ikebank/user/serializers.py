from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.exceptions import PermissionDenied
import re
import user.models as user_models
from user.models import OtpVerification

User = get_user_model()

class CheckPhoneEmailSerializer(serializers.Serializer):
    phone_number = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)

    def validate(self, data):
        phone_number = data.get('phone_number')
        email = data.get('email')

        if not phone_number and not email:
            raise serializers.ValidationError("Either phone number or email must be provided.")

        if phone_number:
            phone_pattern = r'^(?:\+62|62|0)8[1-9][0-9]{6,10}$'
            if not re.match(phone_pattern, phone_number):
                raise serializers.ValidationError("Invalid phone number format.")
            if User.objects.filter(phone_number=phone_number).exists():
                raise serializers.ValidationError("Phone number is already in use.")

        if email:
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, email):
                raise serializers.ValidationError("Invalid email format.")
            if User.objects.filter(email=email).exists():
                raise serializers.ValidationError("Email is already in use.")
        return data


class OtpRequestSerializer(serializers.Serializer):
    email = serializers.EmailField(required=False)
    purpose = serializers.ChoiceField(choices=['registration'], default='registration', required=False)

    def validate(self, data):
        check_serializer = CheckPhoneEmailSerializer(data={
            'email': data.get('email'),
        })
        check_serializer.is_valid(raise_exception=True)
        return {
            **check_serializer.validated_data,
            'purpose': data.get('purpose', 'registration'),
        }


class OtpVerifySerializer(serializers.Serializer):
    reference = serializers.UUIDField(required=True)
    otp_code = serializers.RegexField(regex=r'^\d{6}$', required=True)
    purpose = serializers.ChoiceField(choices=['registration'], default='registration', required=False)


class KtpUploadSerializer(serializers.Serializer):
    reference = serializers.UUIDField(required=True)
    ktp = serializers.ImageField(required=True)
    purpose = serializers.ChoiceField(choices=['registration'], default='registration', required=False)


class FaceUploadSerializer(serializers.Serializer):
    face = serializers.ImageField(required=True)

class RegisterSerializer(serializers.ModelSerializer):
    otp_reference = serializers.UUIDField(write_only=True, required=True)
    purpose = serializers.ChoiceField(choices=['registration'], default='registration', write_only=True, required=False)
    password_confirmation = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    pin_confirmation = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    
    class Meta:
        model = User
        fields = ['otp_reference', 'purpose', 'phone_number', 'email', 'password', 'password_confirmation', 'name', 'ktp', 'nik', 'born_place', 'born_date', 'gender', 'address', 'religion', 'mother_name', 'pin', 'pin_confirmation']
        extra_kwargs = {
            'password': {'write_only': True},
            'pin': {'write_only': True},
            'nik': {'write_only': True},
            'mother_name': {'write_only': True},
        }

    def validate_email(self, value):
        email = value.lower()
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

        if not re.match(email_pattern, email):
            raise serializers.ValidationError("Invalid email format.")
        
        if User.objects.filter(email=email).exists():
            raise serializers.ValidationError("Email is already in use.")
        
        return email
    
    def validate_phone_number(self, value):
        phone_number = value.strip()
        phone_pattern = r'^(?:\+62|62|0)8[1-9][0-9]{6,10}$'

        if not re.match(phone_pattern, phone_number):
            raise serializers.ValidationError("Invalid phone number format.")
        
        if User.objects.filter(phone_number=phone_number).exists():
            raise serializers.ValidationError("Phone number is already in use.")
        
        return phone_number
    
    def validate_nik(self, value):
        nik = value.strip()
        nik_pattern = r'^\d{16}$'

        if not re.match(nik_pattern, nik):
            raise serializers.ValidationError("NIK must be exactly 16 digits.")

        hashed_nik = user_models.hash_nik(nik)
        if User.objects.filter(nik=hashed_nik).exists():
            raise serializers.ValidationError("NIK is already in use.")
        
        return hashed_nik
            
    def validate(self, data):
        otp = OtpVerification.objects.filter(
            reference=data.get('otp_reference'),
            purpose=data.get('purpose', OtpVerification.PURPOSE_REGISTRATION),
        ).first()
        if otp is None:
            raise serializers.ValidationError({'otp_reference': 'OTP reference not found.'})
        if not otp.is_verified:
            raise serializers.ValidationError({'otp_reference': 'OTP is not verified yet.'})

        if data['password'] != data['password_confirmation']:
            raise serializers.ValidationError("Password and password confirmation do not match.")
        if data['pin'] != data['pin_confirmation']:
            raise serializers.ValidationError("PIN and PIN confirmation do not match.")
        return data
    
    def create(self, validated_data):
        validated_data.pop('otp_reference', None)
        validated_data.pop('purpose', None)
        validated_data.pop('password_confirmation', None)
        validated_data.pop('pin_confirmation', None)
        password = validated_data.pop('password')
        if 'biometric_data' in validated_data:
            validated_data['biometric_data'] = user_models.hash_biometric_data(validated_data['biometric_data'])
        validated_data['mother_name'] = user_models.hash_mother_name(validated_data['mother_name'])
        validated_data['pin'] = user_models.hash_pin(validated_data['pin'])
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user
    
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate_email(self, value):
        return value.lower()
    
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['phone_number'] = user.phone_number
        token['email'] = user.email
        token['name'] = user.name
        token['biometric_data'] = user.biometric_data
        return token
    
    def validate(self, attrs):
        data = super().validate(attrs)

        token_data = {
            'access': data['access'],
            'refresh': data['refresh'],
        }

        data.update({
            "phone_number": self.user.phone_number,
            "email": self.user.email,
            "name": self.user.name,
            "biometric_data": self.user.biometric_data,
            "token": token_data,
        })
        return data