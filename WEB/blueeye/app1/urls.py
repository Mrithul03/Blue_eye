from django.urls import path
from .import views
from .views import Myview,Booking,login_user

urlpatterns=[
    path('',Myview.as_view(),name='myview'),
    path('booking',Booking.as_view(),name='booking'),
    path('api/login/', login_user, name='login_user'),
]