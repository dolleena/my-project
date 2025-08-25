from django.contrib import admin
from django.urls import path
from devices.views import register, heartbeat, metrics

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/devices/register", register),
    path("api/devices/heartbeat", heartbeat),
    path("api/devices/metrics", metrics),
]
