from django.shortcuts import render
from django.views import View



class Myview(View):
    def get(self,request):
        return render(request,'index.html')


class Booking(View):
    def get(self,request):
        return render(request,'booking.html')