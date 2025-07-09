from django import forms
from .models import Customer,Package

class BookingForm(forms.ModelForm):
    class Meta:
        model = Customer
        fields = ['name','mobile','destination','members','date_from','date_upto','package','suggestion']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your Name'}),
            'mobile': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your Mobile Number'}),
            'destination': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Enter Your destinations'}),
            'members': forms.NumberInput(attrs={'class': 'form-control', 'placeholder': 'Enter Number Of Members'}),
            'suggestion': forms.TextInput(attrs={'class': 'form-control', 'placeholder':'Tell us about your trip','row':'3'}),
            'date_from': forms.NumberInput(attrs={'class': 'form-control','type':'date'}),
            'date_upto': forms.NumberInput(attrs={'class': 'form-control','type':'date'}),
            'package': forms.Select(attrs={'class': 'form-control','defult':'Select package'}),
            # Add similar for other fields
        }

        # def __init__(self, *args):
        #     super(BookingForm, self).__init__(*args)

        #     # Add "Select" as the default option for place and event
        #     self.fields['package'].choices = [("Select package")] + list(Package.name)
        
        #     # Customize the date field with a date picker widget
        #     self.fields['date_from'].widget = forms.SelectDateWidget()
        #     self.fields['date_upto'].widget = forms.SelectDateWidget()
