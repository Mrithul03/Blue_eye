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
    status = models.CharField(
        max_length=10,
        choices=[
            ('pending', 'Pending'),
            ('confirmed', 'Confirmed'),
            ('declined', 'Declined')
        ],
        default='pending'
    )

