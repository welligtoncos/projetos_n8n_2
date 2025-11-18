import requests

url = "http://localhost:8080/chat/whatsappNumbers/meu_novo_bot"


payload = {"numbers": ["5592993188317"]}
headers = {
    "apikey": "evolution_123456",
    "Content-Type": "application/json"
}

response = requests.request("POST", url, json=payload, headers=headers)

print(response.text)