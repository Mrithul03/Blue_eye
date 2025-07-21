from rest_framework import serializers
from .models import Customer,User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'phone','password', 'user_type','device_token']
        
class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields =['id','name', 'mobile', 'destination', 'members', 'date_from', 'date_upto', 'package', 'suggestion', 'status','driver' ]