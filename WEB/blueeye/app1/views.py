from django.shortcuts import render, redirect
from django.views import View
from .forms import BookingForm
from .models import Customer, UserProfile
from .serializers import UserSerializer, CustomerSerializer

from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework import status
from django.contrib import messages


# === STATIC PAGE VIEWS ===

class Myview(View):
    def get(self, request):
        form = BookingForm()
        return render(request, 'index.html', {'form': form})

    def post(self, request):
        form = BookingForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, "🎉 ✅ Booking successful! Our team will contact you within an hour!")
            return render(request, 'index.html', {'form': BookingForm(), 'msg': messages})
        return render(request, 'index.html', {'form': form})



class Conatct(View):
    def get(self, request):
        return render(request, 'contact.html')


# === API VIEWS ===

@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    phone = request.data.get('phone')
    password = request.data.get('password')

    print(f"📥 Login attempt: phone={phone}, password={password}")

    try:
        profile = UserProfile.objects.get(phone=phone)
        print(f"✅ Found UserProfile: {profile}")

        user = profile.user
        print(f"✅ Linked User: id={user.id}, first_name={user.first_name}, stored_password={user.password}")

        if profile.phone != phone or user.password != password:
            print("❌ Invalid phone or password")
            return Response({'error': 'Invalid credentials'}, status=401)

        Token.objects.filter(user=user).delete()
        token = Token.objects.create(user=user)
        print(f"🔑 New token created: {token.key}")

        profile.device_token = token.key
        profile.save()
        print(f"📦 Saved token in UserProfile.device_token: {profile.device_token}")

        return Response({
            'message': 'Login successful',
            'device_token': token.key,
            'user_id': user.id,
            'name': user.first_name,
            'phone': profile.phone,
            'user_type': profile.user_type,
        }, status=status.HTTP_200_OK)

    except (User.DoesNotExist, UserProfile.DoesNotExist) as e:
        print(f"❌ User does not exist: {e}")
        return Response({'error': 'User does not exist'}, status=404)



@api_view(['GET'])
@permission_classes([IsAuthenticated])
def customer_list(request):
    customers = Customer.objects.all()
    serializer = CustomerSerializer(customers, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_list(request):
    users = User.objects.all().select_related()  # slight optimization
    user_data = []

    for user in users:
        try:
            profile = UserProfile.objects.get(user=user)
            user_type = profile.user_type
        except UserProfile.DoesNotExist:
            user_type = 'Owner'  # default fallback if profile missing
        user_data.append({
            'id': user.id,
            'name': user.first_name,       # stored as name
            'phone': user.username,        # phone stored in username
            'user_type': user_type,
            'device_token': profile.device_token,
        })

    return Response(user_data, status=status.HTTP_200_OK)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_customer(request, pk):
    try:
        customer = Customer.objects.get(pk=pk)
    except Customer.DoesNotExist:
        return Response({'error': 'Customer not found'}, status=status.HTTP_404_NOT_FOUND)

    data = request.data
    customer.status = data.get('status', customer.status)
    customer.driver = data.get('driver', customer.driver)
    customer.save()

    return Response({'message': 'Customer updated'}, status=status.HTTP_200_OK)