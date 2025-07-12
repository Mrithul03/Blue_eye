from django.db import models


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

class User(models.Model):
    name = models.CharField(max_length=100)
    phone = models.CharField(max_length=15, unique=True)
    password = models.CharField(max_length=128)
    user_type = models.CharField(
        max_length=10,
        choices=[
            ('Driver', 'Driver'),
            ('Owner', 'Owner'),
        ],
        default='Owner'
    )
    device_token = models.CharField(max_length=256, blank=True, null=True)


