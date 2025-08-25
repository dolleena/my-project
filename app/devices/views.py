from django.utils import timezone
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Device

@api_view(["POST"])
def register(request):
    d, _ = Device.objects.get_or_create(device_id=request.data["device_id"])
    return Response({"ok": True, "device_id": d.device_id, "config": d.config})

@api_view(["POST"])
def heartbeat(request):
    d, _ = Device.objects.get_or_create(device_id=request.data["device_id"])
    d.last_seen = timezone.now()
    d.hostname = request.data.get("hostname", "")
    d.save()
    return Response({"ok": True})

@api_view(["POST"])
def metrics(request):
    # store or just ack for now
    return Response({"ok": True})
