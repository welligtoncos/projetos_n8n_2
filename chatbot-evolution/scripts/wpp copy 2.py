import requests

BASE_URL = "http://evolution_whatsapp:8080"
API_KEY = "evolution_123456"
INSTANCE_NAME = "meu_novo_bot"

url = f"{BASE_URL}/message/sendText/{INSTANCE_NAME}"

headers = {
    "Content-Type": "application/json",
    "apikey": API_KEY
}

payload = {
    "number": "5561999560044",  # Troque pelo número de destino
    "text": "Teste de envio de mensagem via Evolution API 🚀"
}

try:
    response = requests.post(url, json=payload, headers=headers)
    print(f"Status Code: {response.status_code}")
    print("Resposta da API:", response.text)

    if response.status_code == 200:
        print("✅ Mensagem enviada com sucesso!")
    else:
        print("❌ Falha ao enviar mensagem.")
except requests.exceptions.RequestException as e:
    print("❌ Erro de conexão:", e)
