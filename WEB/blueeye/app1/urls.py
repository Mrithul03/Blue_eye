from django.urls import path
from .import views
from .views import Myview,Booking

urlpatterns=[
    path('',Myview.as_view(),name='myview'),
    path('/booking',Booking.as_view(),name='booking'),
]