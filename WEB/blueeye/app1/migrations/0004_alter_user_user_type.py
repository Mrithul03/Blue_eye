# Generated by Django 5.1.1 on 2025-07-10 06:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0003_user'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='user_type',
            field=models.CharField(choices=[('Driver', 'Driver'), ('Owner', 'Owner')], default='Owner', max_length=10),
        ),
    ]
