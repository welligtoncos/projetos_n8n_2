import requests

# CONFIGURAÇÕES
BASE_URL = "http://localhost:8080"
API_KEY = "evolution_123456"  # Troque pela sua chave real
INSTANCE_NAME = "meu_novo_bot"  # Nome exato da sua instância existente

# Monta o endpoint
url = f"{BASE_URL}/instance/connect/{INSTANCE_NAME}"

# Headers com a API Key
headers = {
    "Content-Type": "application/json",
    "apikey": API_KEY
}

try:
    response = requests.get(url, headers=headers)
    print(f"\n🔎 Status Conexão Instância: {response.status_code}")
    print(f"Resposta: {response.text}")

    if response.status_code == 200:
        print("\n✅ Instância conectada com sucesso!")
    else:
        print("\n❌ Falha ao conectar instância.")

except Exception as e:
    print(f"\n❌ Erro inesperado: {str(e)}")
