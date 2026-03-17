from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.contrib.auth.hashers import make_password
from django.conf import settings
import hashlib


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

class User(AbstractBaseUser, PermissionsMixin):
    GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
        ('Other', 'Other'),
    ]

    RELOGION_CHOICES = [
        ('Islam', 'Islam'),
        ('Christianity', 'Christianity'),
        ('Hinduism', 'Hinduism'),
        ('Buddhism', 'Buddhism'),
        ('Other', 'Other'),
    ]

    phone_number = models.CharField(max_length=15, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    name = models.CharField(max_length=255)
    biometric_data = models.TextField(blank=True, null=True)
    ktp = models.ImageField(upload_to='ktp_images/', blank=False, null=False)
    nik = models.CharField(max_length=64, unique=True, blank=False, null=False)
    born_place = models.CharField(max_length=255, blank=False, null=False)
    born_date = models.DateField(blank=False, null=False)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, blank=False, null=False)
    address = models.TextField(blank=False, null=False)
    religion = models.CharField(max_length=50, choices=RELOGION_CHOICES, blank=False, null=False)
    mother_name = models.CharField(max_length=64, blank=False, null=False)
    pin = models.CharField(max_length=128, blank=False, null=False)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['email', 'name', 'ktp', 'nik', 'born_place', 'born_date', 'gender', 'address', 'religion', 'mother_name', 'pin']
    
    def __str__(self):
        return self.name


