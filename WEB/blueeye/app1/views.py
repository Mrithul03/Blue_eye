from django.shortcuts import render,redirect
from django.views import View
from .forms import BookingForm  

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