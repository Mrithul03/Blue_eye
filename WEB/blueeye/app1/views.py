from django.shortcuts import render,redirect
from django.views import View
from .forms import BookingForm 
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializers import LoginSerializer,UserSerializer 
from  .models import User
import uuid

class Myview(View):
    def get(self,request):
        form=BookingForm(request.POST)
        return render(request,'index.html',{'form':form})
    
    def post(self, request):
     form = BookingForm(request.POST)
     if form.is_valid():
        form.save()
        msg = "Successfully booked! Please check your booking status. We will contact you within 2 hours."
        return render(request, 'index.html', {'form': BookingForm(), 'msg': msg})
     else:
        return render(request, 'index.html', {'form': form})



class Booking(View):
    def get(self,request):
        return render(request,'booking.html')
    

@api_view(['POST'])
def login_user(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        phone = serializer.validated_data['phone']
        password = serializer.validated_data['password']
        user_type = serializer.validated_data['user_type']

        try:
            user = User.objects.get(phone=phone, password=password, user_type=user_type)
        except User.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        # Generate or return device_token
        if not user.device_token:
            user.device_token = str(uuid.uuid4())  # import uuid at the top
            user.save()

        return Response({'device_token': user.device_token}, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)