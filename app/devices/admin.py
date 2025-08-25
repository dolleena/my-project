from django.contrib import admin
from .models import Device
@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ("device_id","hostname","last_seen")
    search_fields = ("device_id","hostname")
