# Generated by Django 5.1.1 on 2025-07-12 13:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app1', '0004_alter_user_user_type'),
    ]

    operations = [
        migrations.AddField(
            model_name='customer',
            name='acceptance',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='customer',
            name='driver',
            field=models.CharField(blank=True, max_length=100),
        ),
    ]
