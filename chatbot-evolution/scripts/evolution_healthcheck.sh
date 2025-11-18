#!/bin/bash

# Configurações
LOG_FILE="/var/log/evolution_health.log"
DISCORD_WEBHOOK="" # Opcional: webhook para notificações
API_KEY="evolution_123456"
INSTANCE_NAME="instancia_1_teste"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log com timestamp
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Função para enviar notificação Discord (opcional)
send_discord_notification() {
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -s -X POST "$DISCORD_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"content\": \"🚨 Evolution API Alert: $1\"}" > /dev/null
    fi
}

echo -e "${BLUE}🔍 Evolution API - Enhanced Health Check${NC}"
echo "========================================"
echo ""

OVERALL_STATUS=0

# 1. Verificar container Evolution
echo -e "${YELLOW}🧱 Verificando container evolution_whatsapp...${NC}"
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "evolution_whatsapp.*Up"; then
    echo -e "${GREEN}✅ Container Evolution API está rodando.${NC}"
    log_with_timestamp "SUCCESS: Container Evolution API running"
else
    echo -e "${RED}❌ Container Evolution API NÃO está rodando!${NC}"
    log_with_timestamp "ERROR: Container Evolution API not running"
    send_discord_notification "Container Evolution API está offline!"
    OVERALL_STATUS=1
fi

echo ""

# 2. Verificar PostgreSQL
echo -e "${YELLOW}🗄️ Testando PostgreSQL...${NC}"
if docker exec evolution_postgres pg_isready -U evolution -q; then
    echo -e "${GREEN}✅ PostgreSQL OK.${NC}"
    log_with_timestamp "SUCCESS: PostgreSQL connection OK"
else
    echo -e "${RED}❌ Problema na conexão com PostgreSQL.${NC}"
    log_with_timestamp "ERROR: PostgreSQL connection failed"
    send_discord_notification "PostgreSQL não está respondendo!"
    OVERALL_STATUS=1
fi

# 2.1. Verificar espaço em disco do PostgreSQL
PG_DISK_USAGE=$(docker exec evolution_postgres df -h /var/lib/postgresql/data | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$PG_DISK_USAGE" -gt 80 ]; then
    echo -e "${YELLOW}⚠️ Aviso: Disco PostgreSQL em ${PG_DISK_USAGE}%${NC}"
    log_with_timestamp "WARNING: PostgreSQL disk usage at ${PG_DISK_USAGE}%"
    send_discord_notification "PostgreSQL disk usage high: ${PG_DISK_USAGE}%"
fi

echo ""

# 3. Verificar Redis (se habilitado)
echo -e "${YELLOW}🔧 Testando Redis...${NC}"
if docker exec evolution_redis redis-cli ping | grep -q "PONG"; then
    echo -e "${GREEN}✅ Redis OK.${NC}"
    log_with_timestamp "SUCCESS: Redis connection OK"
else
    echo -e "${YELLOW}⚠️ Redis não está respondendo (pode estar desabilitado).${NC}"
    log_with_timestamp "WARNING: Redis not responding"
fi

echo ""

# 4. Verificar Chromium
echo -e "${YELLOW}🌐 Verificando Chromium...${NC}"
if docker exec evolution_whatsapp which chromium >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Chromium encontrado.${NC}"
    log_with_timestamp "SUCCESS: Chromium available"
else
    echo -e "${RED}❌ Chromium NÃO encontrado.${NC}"
    log_with_timestamp "ERROR: Chromium not found"
    send_discord_notification "Chromium não encontrado no container!"
    OVERALL_STATUS=1
fi

echo ""

# 5. Testar API Health
echo -e "${YELLOW}🌐 Testando API Evolution /health...${NC}"
HEALTH_RESPONSE=$(curl -s --max-time 10 http://localhost:8080/health)
if echo "$HEALTH_RESPONSE" | grep -q "UP\|OK"; then
    echo -e "${GREEN}✅ API Evolution respondendo /health.${NC}"
    log_with_timestamp "SUCCESS: API health endpoint OK"
else
    echo -e "${RED}❌ API Evolution não respondeu ao /health. Response: $HEALTH_RESPONSE${NC}"
    log_with_timestamp "ERROR: API health endpoint failed - Response: $HEALTH_RESPONSE"
    send_discord_notification "API Evolution health endpoint falhou!"
    OVERALL_STATUS=1
fi

echo ""

# 6. Verificar estado das instâncias
echo -e "${YELLOW}📲 Verificando instâncias WhatsApp...${NC}"
INSTANCES_RESPONSE=$(curl -s --max-time 10 -H "apikey: $API_KEY" http://localhost:8080/instance/fetchInstances)
if [ $? -eq 0 ] && [ -n "$INSTANCES_RESPONSE" ]; then
    echo -e "${GREEN}✅ Conseguiu listar instâncias.${NC}"
    log_with_timestamp "SUCCESS: Instances fetch OK"
    
    # Verificar estado específico da instância
    CONNECTION_STATE=$(curl -s --max-time 10 -H "apikey: $API_KEY" "http://localhost:8080/instance/connectionState/$INSTANCE_NAME" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
    case "$CONNECTION_STATE" in
        "open")
            echo -e "${GREEN}✅ Instância $INSTANCE_NAME: CONECTADA${NC}"
            log_with_timestamp "SUCCESS: Instance $INSTANCE_NAME connected"
            ;;
        "connecting")
            echo -e "${YELLOW}⚠️ Instância $INSTANCE_NAME: CONECTANDO${NC}"
            log_with_timestamp "INFO: Instance $INSTANCE_NAME connecting"
            ;;
        "close"|"")
            echo -e "${RED}❌ Instância $INSTANCE_NAME: DESCONECTADA${NC}"
            log_with_timestamp "WARNING: Instance $INSTANCE_NAME disconnected"
            send_discord_notification "Instância $INSTANCE_NAME está desconectada!"
            ;;
        *)
            echo -e "${YELLOW}⚠️ Instância $INSTANCE_NAME: Estado desconhecido ($CONNECTION_STATE)${NC}"
            log_with_timestamp "WARNING: Instance $INSTANCE_NAME unknown state: $CONNECTION_STATE"
            ;;
    esac
else
    echo -e "${RED}❌ Não conseguiu verificar instâncias.${NC}"
    log_with_timestamp "ERROR: Failed to fetch instances"
    send_discord_notification "Falha ao verificar instâncias WhatsApp!"
    OVERALL_STATUS=1
fi

echo ""

# 7. Verificar uso de memória
echo -e "${YELLOW}💾 Verificando uso de recursos...${NC}"
MEMORY_USAGE=$(docker stats evolution_whatsapp --no-stream --format "{{.MemPerc}}" | sed 's/%//')
if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
    echo -e "${YELLOW}⚠️ Alto uso de memória: ${MEMORY_USAGE}%${NC}"
    log_with_timestamp "WARNING: High memory usage: ${MEMORY_USAGE}%"
    send_discord_notification "Alto uso de memória: ${MEMORY_USAGE}%"
fi

# 8. Verificar logs recentes para erros
echo -e "${YELLOW}📋 Verificando logs recentes...${NC}"
ERROR_COUNT=$(docker logs evolution_whatsapp --since="5m" 2>&1 | grep -i "error\|exception\|failed" | wc -l)
if [ "$ERROR_COUNT" -gt 5 ]; then
    echo -e "${YELLOW}⚠️ Muitos erros nos logs recentes: $ERROR_COUNT${NC}"
    log_with_timestamp "WARNING: High error count in logs: $ERROR_COUNT"
    send_discord_notification "Muitos erros detectados nos logs: $ERROR_COUNT"
fi

echo ""
echo "========================================"

# Status final
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ Health Check APROVADO - Sistema operacional${NC}"
    log_with_timestamp "SUCCESS: Overall health check passed"
else
    echo -e "${RED}❌ Health Check FALHOU - Verificar problemas acima${NC}"
    log_with_timestamp "ERROR: Overall health check failed"
    send_discord_notification "Health Check Evolution API falhou! Verificar sistema."
fi

echo ""
echo -e "${BLUE}📊 Log completo em: $LOG_FILE${NC}"

exit $OVERALL_STATUS