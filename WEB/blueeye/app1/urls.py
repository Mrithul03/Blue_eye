from django.urls import path
from .import views
from .views import Myview,login_user,customer_list,Conatct,user_list,update_customer

urlpatterns=[
    path('',Myview.as_view(),name='myview'),
    path('contact',Conatct.as_view(),name='contact'),
    path('api/login/', login_user, name='login_user'),
    path('api/customers/', customer_list, name='customer_list'),
    path('api/users/', user_list, name='user_list'),
    path('api/customer/<int:pk>/update/', update_customer, name='update-customer'),
]