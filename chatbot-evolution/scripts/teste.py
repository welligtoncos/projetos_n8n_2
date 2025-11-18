import requests
import time
from datetime import datetime

class TesteAposCorrecoes:
    def __init__(self):
        self.base_url = "http://localhost:8080"
        self.api_key = "evolution_123456"
        self.instance_name = "instancia_1_teste"  # ou "chatbot_salao" se criou nova
        self.meu_numero = "5561999560044"
        
        self.headers = {
            "apikey": self.api_key,
            "Content-Type": "application/json"
        }
        self.headers_get = {"apikey": self.api_key}

    def verificar_conexao(self):
        """Verificar se a instância está conectada"""
        print("🔍 VERIFICANDO CONEXÃO")
        print("=" * 40)
        
        try:
            response = requests.get(
                f"{self.base_url}/instance/connectionState/{self.instance_name}",
                headers=self.headers_get
            )
            
            if response.status_code == 200:
                status = response.json()
                state = status.get('instance', {}).get('state', 'N/A')
                print(f"📊 Status: {state}")
                
                if state == "open":
                    print("✅ Instância conectada e pronta!")
                    return True
                else:
                    print(f"❌ Instância não conectada: {state}")
                    return False
            else:
                print(f"❌ Erro: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erro: {e}")
            return False

    def teste_mensagem_simples(self):
        """Teste com mensagem ultra simples"""
        print("\n🧪 TESTE 1: MENSAGEM ULTRA SIMPLES")
        print("=" * 50)
        
        data = {
            "number": self.meu_numero,
            "text": "oi"
        }
        
        try:
            response = requests.post(
                f"{self.base_url}/message/sendText/{self.instance_name}",
                headers=self.headers,
                json=data
            )
            
            if response.status_code in [200, 201]:
                result = response.json()
                msg_id = result.get('key', {}).get('id', 'N/A')
                
                print("✅ Mensagem 'oi' enviada!")
                print(f"🆔 ID: {msg_id}")
                print("📱 Verifique seu WhatsApp!")
                
                # Aguardar resposta do usuário
                time.sleep(5)
                chegou = input("📱 Chegou a mensagem 'oi'? (s/n): ").strip().lower()
                
                if chegou == 's':
                    print("🎉 SUCESSO! Problema resolvido!")
                    return True
                else:
                    print("❌ Ainda não chegou, vamos tentar outros formatos")
                    return False
                    
            else:
                print(f"❌ Erro: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erro: {e}")
            return False

    def teste_formatos_diferentes(self):
        """Testar formatos diferentes após correções"""
        print("\n🧪 TESTE 2: FORMATOS DIFERENTES")
        print("=" * 50)
        
        formatos_teste = [
            {
                "numero": self.meu_numero,
                "texto": "teste 1 - formato simples"
            },
            {
                "numero": f"{self.meu_numero}@c.us",
                "texto": "teste 2 - formato @c.us"
            },
            {
                "numero": self.meu_numero,
                "texto": "Teste 3 sem emojis e sem caracteres especiais"
            }
        ]
        
        sucessos = 0
        
        for i, teste in enumerate(formatos_teste, 1):
            print(f"\n📱 Teste {i}: {teste['numero']}")
            print(f"💬 Texto: {teste['texto']}")
            
            data = {
                "number": teste['numero'],
                "text": teste['texto']
            }
            
            try:
                response = requests.post(
                    f"{self.base_url}/message/sendText/{self.instance_name}",
                    headers=self.headers,
                    json=data
                )
                
                if response.status_code in [200, 201]:
                    result = response.json()
                    msg_id = result.get('key', {}).get('id', 'N/A')
                    print(f"✅ Enviado! ID: {msg_id}")
                    sucessos += 1
                else:
                    print(f"❌ Falhou: {response.text}")
                    
            except Exception as e:
                print(f"❌ Erro: {e}")
            
            # Delay entre mensagens
            time.sleep(3)
        
        print(f"\n📊 Resultados: {sucessos}/{len(formatos_teste)} sucessos")
        
        if sucessos > 0:
            print("⏳ Aguarde 30 segundos e verifique seu WhatsApp...")
            time.sleep(30)
            
            total_chegaram = input(f"📱 Quantas das {sucessos} mensagens chegaram? (0-{sucessos}): ")
            try:
                chegaram = int(total_chegaram)
                if chegaram > 0:
                    print(f"🎉 {chegaram} mensagens chegaram! Problema parcialmente resolvido!")
                    return True
                else:
                    print("❌ Nenhuma mensagem chegou ainda")
                    return False
            except:
                print("❌ Resposta inválida")
                return False
        else:
            return False

    def teste_business_format(self):
        """Teste com formato WhatsApp Business oficial"""
        print("\n🧪 TESTE 3: FORMATO WHATSAPP BUSINESS")
        print("=" * 50)
        
        # Formato mais profissional
        data = {
            "number": f"{self.meu_numero}@c.us",
            "text": "Olá! Esta é uma mensagem de teste do sistema.",
            "quoted": {},
            "mentions": []
        }
        
        try:
            response = requests.post(
                f"{self.base_url}/message/sendText/{self.instance_name}",
                headers=self.headers,
                json=data
            )
            
            if response.status_code in [200, 201]:
                result = response.json()
                msg_id = result.get('key', {}).get('id', 'N/A')
                
                print("✅ Mensagem business enviada!")
                print(f"🆔 ID: {msg_id}")
                print("⏳ Aguardando 15 segundos...")
                
                time.sleep(15)
                chegou = input("📱 Chegou a mensagem business? (s/n): ").strip().lower()
                
                if chegou == 's':
                    print("🎉 FORMATO BUSINESS FUNCIONOU!")
                    return True
                else:
                    print("❌ Formato business também não funcionou")
                    return False
                    
            else:
                print(f"❌ Erro: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erro: {e}")
            return False

    def teste_outro_numero(self):
        """Teste enviando para outro número"""
        print("\n🧪 TESTE 4: OUTRO NÚMERO")
        print("=" * 50)
        
        outro_numero = "5521971129047"
        
        data = {
            "number": f"{outro_numero}@c.us",
            "text": "Teste para outro numero - você recebeu esta mensagem?"
        }
        
        try:
            response = requests.post(
                f"{self.base_url}/message/sendText/{self.instance_name}",
                headers=self.headers,
                json=data
            )
            
            if response.status_code in [200, 201]:
                result = response.json()
                msg_id = result.get('key', {}).get('id', 'N/A')
                
                print(f"✅ Mensagem para {outro_numero} enviada!")
                print(f"🆔 ID: {msg_id}")
                print("📱 Peça para a pessoa verificar o WhatsApp")
                
                chegou = input("📱 A pessoa recebeu? (s/n): ").strip().lower()
                
                if chegou == 's':
                    print("🎉 FUNCIONOU PARA OUTRO NÚMERO!")
                    print("💡 O problema pode ser específico do seu número")
                    return True
                else:
                    print("❌ Também não funcionou para outro número")
                    return False
                    
            else:
                print(f"❌ Erro: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Erro: {e}")
            return False

    def diagnostico_final(self):
        """Diagnóstico final baseado nos testes"""
        print("\n🔧 DIAGNÓSTICO FINAL")
        print("=" * 50)
        
        print("💡 POSSÍVEIS PRÓXIMOS PASSOS:")
        print()
        print("1. 🔄 Desconectar e reconectar o WhatsApp completamente")
        print("2. 📱 Verificar se há atualizações do WhatsApp")
        print("3. 🚫 Verificar se seu número não está com restrições")
        print("4. 🏢 Considerar usar conta WhatsApp diferente")
        print("5. ⏰ Aguardar algumas horas (às vezes demora para normalizar)")
        
        print(f"\n🌐 Manager: http://localhost:8080/manager")
        print("📱 Verifique também a pasta de mensagens arquivadas no WhatsApp")

def main():
    """Executar todos os testes após correções"""
    
    tester = TesteAposCorrecoes()
    
    print("🚀 TESTE PÓS-CORREÇÕES")
    print("=" * 60)
    print("🎯 Objetivo: Verificar se as correções resolveram o problema")
    print("=" * 60)
    
    # 1. Verificar conexão
    if not tester.verificar_conexao():
        print("\n❌ Instância não conectada! Conecte primeiro no manager.")
        return
    
    # 2. Teste simples
    if tester.teste_mensagem_simples():
        print("\n🎉 PROBLEMA RESOLVIDO! Sistema funcionando!")
        return
    
    # 3. Testes com formatos diferentes
    if tester.teste_formatos_diferentes():
        print("\n🎉 ALGUMAS MENSAGENS FUNCIONARAM!")
        return
    
    # 4. Teste formato business
    if tester.teste_business_format():
        print("\n🎉 FORMATO BUSINESS FUNCIONOU!")
        return
    
    # 5. Teste outro número
    if tester.teste_outro_numero():
        print("\n🎉 FUNCIONA PARA OUTROS NÚMEROS!")
        print("💡 Problema específico do seu número")
        return
    
    # 6. Se nada funcionou
    print("\n❌ NENHUM TESTE FUNCIONOU")
    tester.diagnostico_final()

if __name__ == "__main__":
    main()