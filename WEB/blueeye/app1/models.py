from django.db import models
from django.contrib.auth.models import User


class Package(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True)

class Customer(models.Model):
    name = models.CharField(max_length=30)
    mobile = models.CharField(max_length=15)  
    destination = models.CharField(max_length=500)
    members = models.PositiveIntegerField() 
    date_from = models.DateField()
    date_upto = models.DateField()
    package = models.ForeignKey(Package, on_delete=models.SET_NULL, null=True, blank=True)
    suggestion = models.TextField() 
    driver = models.CharField(max_length=100, blank=True)
    acceptance = models.BooleanField(default=False)
    status = models.CharField(
        max_length=10,
        choices=[
            ('pending', 'Pending'),
            ('confirmed', 'Confirmed'),
            ('declined', 'Declined')
        ],
        default='pending'
    )

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=15, unique=True)
    device_token = models.CharField(max_length=256, blank=True, null=True)
    user_type = models.CharField(
        max_length=10,
        choices=[('Driver', 'Driver'), ('Owner', 'Owner')],
        default='Owner'
    )

