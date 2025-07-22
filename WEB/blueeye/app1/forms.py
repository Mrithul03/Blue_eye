from django import forms
from .models import Customer
import datetime

class BookingForm(forms.ModelForm):
    class Meta:
        model = Customer
        fields = ['name', 'mobile', 'destination', 'members', 'date_from', 'date_upto', 'package', 'suggestion']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your Name'}),
            'mobile': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your Mobile Number'}),
            'destination': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your destinations'}),
            'members': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Enter Number Of Members'}),
            'suggestion': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Tell us about your trip', 'rows': '3'}),
            'date_from': forms.DateInput(attrs={'type': 'date', 'class': 'form-control', 'id': 'id_date_from'}),
            'date_upto': forms.DateInput(attrs={'type': 'date', 'class': 'form-control', 'id': 'id_date_upto'}),
            'package': forms.Select(attrs={'class': 'form-control'}),
        }

    def __init__(self, *args, **kwargs):
        super(BookingForm, self).__init__(*args, **kwargs)
        today = datetime.date.today()
        self.fields['date_from'].widget.attrs['min'] = today.strftime('%Y-%m-%d')
        self.fields['date_upto'].widget.attrs['min'] = today.strftime('%Y-%m-%d')

        # ✅ Make 'suggestion' optional
        self.fields['suggestion'].required = False
