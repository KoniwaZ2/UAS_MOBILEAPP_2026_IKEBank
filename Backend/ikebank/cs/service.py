import requests
from django.conf import settings

def get_intent(message):
    try:
        url = settings.N8N_WEBHOOK.rstrip("/") + "/"

        res = requests.post(
            url,
            json={"message": message},
            headers={"Content-Type": "application/json"},
            timeout=5
        )

        data = res.json()
        return data.get("intent", "UNKNOWN")

    except Exception as e:
        return "ERROR"