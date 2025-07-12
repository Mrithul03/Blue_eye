from django.urls import path
from .import views
from .views import Myview,Booking,login_user,customer_list,Conatct

urlpatterns=[
    path('',Myview.as_view(),name='myview'),
    path('contact',Conatct.as_view(),name='contact'),
    path('api/login/', login_user, name='login_user'),
    path('api/customers/', customer_list, name='customer_list'),
]