# serializers.py
from rest_framework import serializers
from .models import User

class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField()
    password = serializers.CharField()
    user_type = serializers.ChoiceField(choices=['Driver', 'Owner'], default='Owner')


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'phone', 'user_type', 'device_token']
