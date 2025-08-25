import os, socket, time, requests
API_BASE = os.getenv("API_BASE","http://edgewatch.local")
DEVICE_ID = os.getenv("DEVICE_ID","qemu-x86")
while True:
    try:
        requests.post(f"{API_BASE}/api/devices/register", json={"device_id": DEVICE_ID})
        requests.post(f"{API_BASE}/api/devices/heartbeat", json={"device_id": DEVICE_ID, "hostname": socket.gethostname()})
    except Exception:
        pass
    time.sleep(30)
