# teste_business.py - Formato business oficial
import requests

def enviar_formato_business():
    headers = {
        "apikey": "evolution_123456",
        "Content-Type": "application/json"
    }
    
    # Formato oficial do WhatsApp Business
    data = {
        "number": "5561999560044@c.us",
        "textMessage": {
            "text": "Olá! Esta é uma mensagem do sistema."
        }
    }
    
    response = requests.post(
        "http://localhost:8080/message/sendText/instancia_1_teste",
        headers=headers,
        json=data
    )
    
    print(f"Status: {response.status_code}")
    print(f"Resposta: {response.text}")

enviar_formato_business()