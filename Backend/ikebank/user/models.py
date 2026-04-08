from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.contrib.auth.hashers import make_password
from django.conf import settings
from django.utils import timezone
from datetime import timedelta
import secrets
import uuid
import hashlib
from PIL import Image

#hashing functions with pepper for sensitive data like NIK, biometric data, mother name, and PIN
def _hash_with_pepper(value, namespace):
    normalized_value = str(value).strip().lower()
    raw = f"{namespace}:{normalized_value}:{settings.SECRET_KEY}"
    return hashlib.sha256(raw.encode('utf-8')).hexdigest()


def hash_nik(nik):
    return _hash_with_pepper(nik, 'nik')


def hash_biometric_data(biometric_data):
    return _hash_with_pepper(biometric_data, 'biometric_data')


def hash_mother_name(mother_name):
    return _hash_with_pepper(mother_name, 'mother_name')


def hash_pin(pin):
    return make_password(str(pin).strip())


def hash_otp_code(otp_code):
    return _hash_with_pepper(otp_code, 'otp_code')


def generate_otp_code(length=6):
    upper_bound = 10 ** length
    value = secrets.randbelow(upper_bound)
    return f"{value:0{length}d}"


def upload_face_image_to(instance, filename):
    """Generate upload path for face image based on user email"""
    email = instance.email.lower().split('@')[0]  # Get email prefix
    ext = filename.split('.')[-1]  # Get file extension
    return f'face_images/{email}/face.{ext}'


def upload_ktp_image_to(instance, filename):
    """Generate upload path for KTP image based on user email"""
    email = instance.email.lower().split('@')[0]  # Get email prefix
    ext = filename.split('.')[-1]  # Get file extension
    return f'ktp_images/{email}/ktp.{ext}'


def extract_face_encoding(image_file, width=16, height=8):
    """Build a lightweight, deterministic 128-dim face encoding from image pixels."""
    if not image_file:
        return None

    try:
        image_file.seek(0)
        image = Image.open(image_file).convert('L').resize((width, height))
        pixels = list(image.getdata())
        encoding = [round(pixel / 255.0, 6) for pixel in pixels]
        image_file.seek(0)
        return encoding
    except Exception:
        try:
            image_file.seek(0)
        except Exception:
            pass
        return None

# User manager
class UserManager(BaseUserManager):
    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError('Phone number must be provided')

        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        extra_fields.setdefault('is_active', True)

        user = self.model(phone_number=phone_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(phone_number, password, **extra_fields)

# User model
class User(AbstractBaseUser, PermissionsMixin):
    GENDER_CHOICES = [
        ('MALE', 'MALE'),
        ('FEMALE', 'FEMALE'),
        ('OTHER', 'OTHER'),
    ]

    RELOGION_CHOICES = [
        ('ISLAM', 'ISLAM'),
        ('CHRISTIANITY', 'CHRISTIANITY'),
        ('HINDUISM', 'HINDUISM'),
        ('BUDDHISM', 'BUDDHISM'),
        ('OTHER', 'OTHER'),
    ]
    
    id = models.BigAutoField(primary_key=True)
    phone_number = models.CharField(max_length=15, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    name = models.CharField(max_length=255)
    face_encoding = models.JSONField(blank=True, null=True)  # Store face embedding as a list of floats
    face_image = models.ImageField(upload_to=upload_face_image_to, blank=False, null=False, default='face_images/default_face.png')  # Face image saved as face_images/{email}/face.{ext}
    ktp = models.ImageField(upload_to=upload_ktp_image_to, blank=True, null=True)  # KTP image saved as ktp_images/{email}/ktp.{ext}
    nik = models.CharField(max_length=64, unique=True, blank=True, null=True)
    born_place = models.CharField(max_length=255, blank=False, null=False)
    born_date = models.DateField(blank=False, null=False)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, blank=False, null=False)
    address = models.TextField(blank=False, null=False)
    religion = models.CharField(max_length=50, choices=RELOGION_CHOICES, blank=False, null=False)
    mother_name = models.CharField(max_length=64, blank=False, null=False)
    pin = models.CharField(max_length=128, blank=False, null=False)
    nabung_ai_auto_isi = models.BooleanField(default=True)
    nabung_ai_cooldown_until = models.DateTimeField(null=True, blank=True)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['phone_number', 'name', 'ktp', 'nik', 'born_place', 'born_date', 'gender', 'address', 'religion', 'mother_name', 'pin']
    
    def __str__(self):
        return self.name


class OtpVerification(models.Model):
    # ubah capslok smua
    CHANNEL_SMS = 'sms'
    CHANNEL_EMAIL = 'email'
    CHANNEL_CHOICES = [
        (CHANNEL_SMS, 'SMS'),
        (CHANNEL_EMAIL, 'Email'),
    ]

    PURPOSE_REGISTRATION = 'registration'
    PURPOSE_LOGIN = 'login'
    PURPOSE_CHOICES = [
        (PURPOSE_REGISTRATION, 'Registration'),
        (PURPOSE_LOGIN, 'Login'),
    ]

    id = models.BigAutoField(primary_key=True)
    reference = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    channel = models.CharField(max_length=10, choices=CHANNEL_CHOICES)
    destination = models.CharField(max_length=255)
    purpose = models.CharField(max_length=30, choices=PURPOSE_CHOICES, default=PURPOSE_REGISTRATION)
    otp_code_hash = models.CharField(max_length=64)
    is_verified = models.BooleanField(default=False)
    attempt_count = models.PositiveSmallIntegerField(default=0)
    max_attempts = models.PositiveSmallIntegerField(default=5)
    expires_at = models.DateTimeField()
    verified_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['channel', 'destination', 'purpose']),
            models.Index(fields=['expires_at']),
        ]

    def is_expired(self):
        return timezone.now() >= self.expires_at

    def verify_code(self, otp_code):
        if self.is_verified or self.is_expired() or self.attempt_count >= self.max_attempts:
            return False

        self.attempt_count += 1
        if hash_otp_code(otp_code) == self.otp_code_hash:
            self.is_verified = True
            self.verified_at = timezone.now()
            self.save(update_fields=['attempt_count', 'is_verified', 'verified_at', 'updated_at'])
            return True

        self.save(update_fields=['attempt_count', 'updated_at'])
        return False

    @staticmethod
    def get_default_expiry(minutes=5):
        return timezone.now() + timedelta(minutes=minutes)


class RegistrationDraft(models.Model):
    id = models.BigAutoField(primary_key=True)
    otp_reference = models.OneToOneField(
        OtpVerification,
        on_delete=models.CASCADE,
        related_name='registration_draft',
    )
    ktp_image = models.ImageField(upload_to='ktp_images/drafts/', null=True, blank=True)
    face_image = models.ImageField(upload_to='face_images/drafts/', null=True, blank=True)
    face_encoding = models.JSONField(blank=True, null=True)
    extracted_identity = models.JSONField(default=dict)
    is_ktp_confirmed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['is_ktp_confirmed']),
        ]


