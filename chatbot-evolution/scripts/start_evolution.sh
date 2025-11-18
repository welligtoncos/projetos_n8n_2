#!/bin/bash

# Configurações
EVOLUTION_VERSION="2.2.2"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="./logs/start_evolution.log"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

echo -e "${BLUE}🚀 Evolution API - Inicialização Inteligente v2.0${NC}"
echo "=================================================="
echo ""

# Verificar se docker-compose existe
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Arquivo docker-compose.yml não encontrado!${NC}"
    exit 1
fi

# Criar diretórios necessários
mkdir -p logs backups data/{postgres,redis,evolution/{instances,store},n8n}

# 1. Verificar status atual
echo -e "${YELLOW}🔍 Verificando status atual...${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}ℹ️ Containers já estão rodando${NC}"
    
    read -p "Deseja reiniciar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelado pelo usuário."
        exit 0
    fi
else
    echo -e "${YELLOW}ℹ️ Nenhum container rodando${NC}"
fi

echo ""

# 2. Backup de dados (opcional mas recomendado)
echo -e "${YELLOW}💾 Criando backup dos dados...${NC}"
if [ -d "./data" ]; then
    mkdir -p "$BACKUP_DIR"
    
    # Backup do PostgreSQL se estiver rodando
    if docker ps | grep -q "evolution_postgres"; then
        echo "Fazendo backup do PostgreSQL..."
        docker exec evolution_postgres pg_dump -U evolution evolution > "$BACKUP_DIR/postgres_backup.sql"
        log "PostgreSQL backup created: $BACKUP_DIR/postgres_backup.sql"
    fi
    
    # Backup das instâncias Evolution
    if [ -d "./data/evolution" ]; then
        cp -r ./data/evolution "$BACKUP_DIR/"
        log "Evolution data backup created: $BACKUP_DIR/evolution"
    fi
    
    echo -e "${GREEN}✅ Backup criado em: $BACKUP_DIR${NC}"
else
    echo -e "${YELLOW}⚠️ Nenhum dado para backup encontrado${NC}"
fi

echo ""

# 3. Parar containers com timeout
echo -e "${YELLOW}🛑 Parando containers antigos...${NC}"
if docker-compose ps | grep -q "Up"; then
    docker-compose down --timeout 30
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Containers parados com sucesso${NC}"
        log "Containers stopped successfully"
    else
        echo -e "${RED}❌ Erro ao parar containers${NC}"
        log "ERROR: Failed to stop containers"
        exit 1
    fi
else
    echo -e "${YELLOW}ℹ️ Nenhum container para parar${NC}"
fi

echo ""

# 4. Limpeza seletiva (mais segura)
echo -e "${YELLOW}🧹 Limpeza seletiva do Docker...${NC}"
read -p "Deseja fazer limpeza completa do Docker? Isso pode afetar outros projetos (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -a --force
    echo -e "${GREEN}✅ Limpeza completa realizada${NC}"
    log "Full Docker cleanup performed"
else
    # Limpeza mais conservadora
    docker image prune -f
    docker container prune -f
    echo -e "${GREEN}✅ Limpeza conservadora realizada${NC}"
    log "Conservative Docker cleanup performed"
fi

echo ""

# 5. Verificar e atualizar imagens
echo -e "${YELLOW}⬇️ Verificando atualizações...${NC}"

# Verificar se a imagem Evolution está atualizada
CURRENT_IMAGE=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.CreatedAt}}" | grep "evolution-api:$EVOLUTION_VERSION")
if [ -n "$CURRENT_IMAGE" ]; then
    echo -e "${GREEN}ℹ️ Imagem Evolution API $EVOLUTION_VERSION já existe localmente${NC}"
    echo "Criada em: $CURRENT_IMAGE"
    
    read -p "Deseja forçar download da imagem mais recente? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker pull "ghcr.io/atendai/evolution-api:$EVOLUTION_VERSION"
        log "Forced pull of Evolution API image"
    fi
else
    echo "Baixando Evolution API $EVOLUTION_VERSION..."
    docker pull "ghcr.io/atendai/evolution-api:$EVOLUTION_VERSION"
    log "Downloaded Evolution API image version $EVOLUTION_VERSION"
fi

# Atualizar outras imagens
echo "Atualizando outras imagens..."
docker-compose pull
log "Updated all docker-compose images"

echo ""

# 6. Verificar configurações
echo -e "${YELLOW}⚙️ Verificando configurações...${NC}"

# Verificar se as portas estão livres
PORTS_TO_CHECK=("5432" "6379" "8080" "5678")
for port in "${PORTS_TO_CHECK[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ Porta $port já está em uso${NC}"
        log "WARNING: Port $port already in use"
    fi
done

# Verificar espaço em disco
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo -e "${RED}⚠️ AVISO: Pouco espaço em disco disponível (${DISK_USAGE}% usado)${NC}"
    log "WARNING: Low disk space: ${DISK_USAGE}%"
    read -p "Continuar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# 7. Inicializar containers
echo -e "${YELLOW}🚀 Iniciando containers...${NC}"
docker-compose up -d

# Verificar se subiram corretamente
sleep 5
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Containers iniciados com sucesso!${NC}"
    log "Containers started successfully"
else
    echo -e "${RED}❌ Erro ao iniciar containers${NC}"
    log "ERROR: Failed to start containers"
    echo "Verificando logs..."
    docker-compose logs --tail=50
    exit 1
fi

echo ""

# 8. Aguardar inicialização completa
echo -e "${YELLOW}⏳ Aguardando inicialização completa...${NC}"
echo "Verificando saúde dos serviços..."

# Aguardar PostgreSQL
echo -n "PostgreSQL: "
for i in {1..30}; do
    if docker exec evolution_postgres pg_isready -U evolution >/dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Aguardar Evolution API
echo -n "Evolution API: "
for i in {1..60}; do
    if curl -s http://localhost:8080/health >/dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Aguardar N8N
echo -n "N8N: "
for i in {1..30}; do
    if curl -s http://localhost:5678 >/dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""

# 9. Informações finais
echo "=================================================="
echo -e "${GREEN}🎉 Sistema Evolution API iniciado com sucesso!${NC}"
echo ""
echo -e "${BLUE}📍 URLs de Acesso:${NC}"
echo "🌐 Evolution API Manager: http://localhost:8080/manager"
echo "🌐 Evolution API Docs: http://localhost:8080/docs"
echo "🌐 N8N Automação: http://localhost:5678"
echo ""
echo -e "${BLUE}🔧 Comandos Úteis:${NC}"
echo "📋 Ver logs Evolution: docker logs -f evolution_whatsapp"
echo "📋 Ver logs PostgreSQL: docker logs -f evolution_postgres"
echo "📋 Ver logs N8N: docker logs -f n8n_gemini"
echo "📊 Status containers: docker-compose ps"
echo "🔍 Health Check: ./evolution_heathcheck.sh"
echo ""
echo -e "${BLUE}📁 Arquivos Importantes:${NC}"
echo "📄 Log de inicialização: $LOG_FILE"
echo "💾 Backup criado em: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}⚠️ Próximos passos:${NC}"
echo "1. Acesse o Manager em http://localhost:8080/manager"
echo "2. Crie sua primeira instância WhatsApp"
echo "3. Configure automações no N8N"
echo "4. Execute health check regularmente"

log "Evolution API startup completed successfully"

# 10. Executar health check automático
echo ""
if [ -f "./evolution_heathcheck.sh" ]; then
    echo -e "${YELLOW}🔍 Executando health check automático...${NC}"
    chmod +x ./evolution_heathcheck.sh
    ./evolution_heathcheck.sh
else
    echo -e "${YELLOW}💡 Dica: Crie um script de health check para monitoramento${NC}"
fi