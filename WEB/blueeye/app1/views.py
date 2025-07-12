from django.shortcuts import render,redirect
from django.views import View
from .forms import BookingForm 
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializers import UserSerializer,CustomerSerializer
from  .models import User,Customer
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
    
class Conatct(View):
    def get(self,request):
        return render(request,'contact.html')
    

@api_view(['POST'])
def login_user(request):
    data = request.data
    phone = data.get('phone')
    password = data.get('password')

    try:
        user = User.objects.get(phone=phone)

        # Check password
        if user.password != password:
            return Response({'error': 'Invalid password'}, status=status.HTTP_401_UNAUTHORIZED)

        # Generate and update new device token
        user.device_token = str(uuid.uuid4())
        user.save()

        return Response({'device_token': user.device_token}, status=status.HTTP_200_OK)

    except User.DoesNotExist:
        # Register new user if not found
        name = data.get('name')
        user_type = data.get('user_type')
        device_token = str(uuid.uuid4())

        user = User.objects.create(
            name=name,
            phone=phone,
            password=password,
            user_type=user_type,
            device_token=device_token
        )

        return Response({'device_token': user.device_token}, status=status.HTTP_200_OK)

@api_view(['GET'])
def customer_list(request):
    customers = Customer.objects.all()  # Fetch all customers
    serializer = CustomerSerializer(customers, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

