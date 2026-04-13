from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework.exceptions import PermissionDenied
import user.models as user_models

class FaceVerificationSerializer(serializers.Serializer):
    face = serializers.ImageField(required=True)

class ReportSerializer(serializers.Serializer):
    report_number = serializers.CharField(required=True)