from django.db import models

class Device(models.Model):
    device_id = models.CharField(max_length=64, unique=True)
    last_seen = models.DateTimeField(null=True, blank=True)
    hostname = models.CharField(max_length=128, blank=True)
    config = models.JSONField(default=dict)

    def __str__(self):
        return self.device_id
