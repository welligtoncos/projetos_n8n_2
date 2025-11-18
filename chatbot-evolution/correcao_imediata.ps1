# CORREÇÃO IMEDIATA - Evolution API
Write-Host "🔥 CORREÇÃO IMEDIATA EVOLUTION API" -ForegroundColor Red
Write-Host "===================================" -ForegroundColor Red
Write-Host ""

# 1. Parar tudo
Write-Host "1. Parando todos os containers..." -ForegroundColor Yellow
docker-compose down --timeout 10

# 2. Remover container e imagem problemática
Write-Host "2. Removendo container e imagem problemática..." -ForegroundColor Yellow
docker rm -f evolution_whatsapp 2>$null
docker rmi evolution-api-custom 2>$null

# 3. Fazer backup do docker-compose atual
Write-Host "3. Fazendo backup do docker-compose atual..." -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Copy-Item "docker-compose.yml" "docker-compose.yml.backup"
    Write-Host "✅ Backup salvo: docker-compose.yml.backup" -ForegroundColor Green
}

# 4. Criar docker-compose.yml CORRIGIDO
Write-Host "4. Criando docker-compose.yml corrigido..." -ForegroundColor Yellow
$dockerComposeContent = @'
services:
  postgres:
    image: postgres:15-alpine
    container_name: evolution_postgres
    environment:
      POSTGRES_DB: evolution
      POSTGRES_USER: evolution
      POSTGRES_PASSWORD: evolution_password
    ports:
      - "5432:5432"
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    restart: always
    networks:
      - chatbot_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U evolution"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: evolution_redis
    ports:
      - "6379:6379"
    volumes:
      - ./data/redis:/data
    restart: always
    networks:
      - chatbot_network
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  evolution-api:
    image: ghcr.io/atendai/evolution-api:2.2.2
    container_name: evolution_whatsapp
    ports:
      - "8080:8080"
    environment:
      SERVER_URL: http://localhost:8080
      SERVER_PORT: 8080
      AUTHENTICATION_API_KEY: evolution_123456
      AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES: "true"
      DATABASE_ENABLED: "true"
      DATABASE_PROVIDER: postgresql
      DATABASE_CONNECTION_URI: postgresql://evolution:evolution_password@postgres:5432/evolution
      DATABASE_CONNECTION_CLIENT_NAME: evolution_api
      DATABASE_SAVE_DATA_INSTANCE: "true"
      DATABASE_SAVE_DATA_NEW_MESSAGE: "true"
      DATABASE_SAVE_MESSAGE_UPDATE: "true"
      DATABASE_SAVE_DATA_CONTACTS: "true"
      DATABASE_SAVE_DATA_CHATS: "true"
      REDIS_ENABLED: "false"
      QRCODE_LIMIT: 30
      QRCODE_COLOR: "#175197"
      CORS_ORIGIN: "*"
      CORS_METHODS: GET,POST,PUT,DELETE
      CORS_CREDENTIALS: "true"
      LOG_LEVEL: DEBUG
      LOG_COLOR: "true"
      LOG_BAILEYS: error
      DEL_INSTANCE: "false"
      DEL_TEMP_INSTANCES: "true"
      WEBSOCKET_ENABLED: "false"
      CLEAN_STORE_CLEANING_INTERVAL: 7200
      CLEAN_STORE_MESSAGES: "true"
      CLEAN_STORE_MESSAGE_UP_TO: "false"
      CLEAN_STORE_CONTACTS: "true"
      CLEAN_STORE_CHATS: "true"
      NODE_OPTIONS: "--max-old-space-size=512"
    volumes:
      - ./data/evolution/instances:/evolution/instances
      - ./data/evolution/store:/evolution/store
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - chatbot_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n_gemini
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_METRICS=true
    ports:
      - "5678:5678"
    volumes:
      - ./data/n8n:/home/node/.n8n
    restart: always
    depends_on:
      - evolution-api
    networks:
      - chatbot_network

networks:
  chatbot_network:
    driver: bridge
'@

$dockerComposeContent | Out-File -FilePath "docker-compose.yml" -Encoding UTF8
Write-Host "✅ docker-compose.yml corrigido criado!" -ForegroundColor Green

# 5. Renomear Dockerfile problemático
Write-Host "5. Renomeando Dockerfile problemático..." -ForegroundColor Yellow
if (Test-Path "Dockerfile") {
    Move-Item "Dockerfile" "Dockerfile.backup" -Force
    Write-Host "✅ Dockerfile renomeado para Dockerfile.backup" -ForegroundColor Green
}

# 6. Baixar imagem oficial
Write-Host "6. Baixando imagem Evolution API oficial..." -ForegroundColor Yellow
docker pull ghcr.io/atendai/evolution-api:2.2.2
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Imagem oficial baixada!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao baixar imagem" -ForegroundColor Red
    exit 1
}

# 7. Iniciar PostgreSQL primeiro
Write-Host "7. Iniciando PostgreSQL..." -ForegroundColor Yellow
docker-compose up -d postgres
Write-Host "Aguardando PostgreSQL ficar pronto..."
for ($i = 1; $i -le 30; $i++) {
    Start-Sleep 2
    $pgReady = docker exec evolution_postgres pg_isready -U evolution 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL pronto!" -ForegroundColor Green
        break
    }
    Write-Host "⏳ Aguardando PostgreSQL... ($i/30)" -ForegroundColor Gray
}

# 8. Iniciar Redis
Write-Host "8. Iniciando Redis..." -ForegroundColor Yellow
docker-compose up -d redis
Start-Sleep 5
$redisTest = docker exec evolution_redis redis-cli ping 2>$null
if ($redisTest -eq "PONG") {
    Write-Host "✅ Redis pronto!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Redis pode não estar pronto ainda" -ForegroundColor Yellow
}

# 9. Iniciar Evolution API
Write-Host "9. Iniciando Evolution API..." -ForegroundColor Yellow
docker-compose up -d evolution-api

Write-Host "10. Aguardando Evolution API inicializar (90 segundos)..."
for ($i = 1; $i -le 18; $i++) {
    Start-Sleep 5
    $status = docker ps --filter "name=evolution_whatsapp" --filter "status=running" --quiet 2>$null
    if ($status) {
        Write-Host "✅ Container está rodando! Testando API..." -ForegroundColor Green
        
        # Testar API
        try {
            $health = Invoke-RestMethod -Uri "http://localhost:8080/health" -TimeoutSec 10 -ErrorAction Stop
            Write-Host "🎉 API FUNCIONANDO!" -ForegroundColor Green
            Write-Host "Response: $health" -ForegroundColor Cyan
            break
        } catch {
            Write-Host "⏳ API ainda inicializando... ($i/18)" -ForegroundColor Gray
        }
    } else {
        Write-Host "⏳ Container ainda inicializando... ($i/18)" -ForegroundColor Gray
        
        # Verificar se há erros
        $containerStatus = docker ps -a --filter "name=evolution_whatsapp" --format "{{.Status}}"
        if ($containerStatus -like "*Exited*" -or $containerStatus -like "*Restarting*") {
            Write-Host "❌ Container com problema: $containerStatus" -ForegroundColor Red
            Write-Host "Logs do erro:" -ForegroundColor Yellow
            docker logs --tail=10 evolution_whatsapp
            break
        }
    }
}

# 11. Iniciar N8N
Write-Host "11. Iniciando N8N..." -ForegroundColor Yellow
docker-compose up -d n8n

# 12. Status final
Write-Host "`n📊 STATUS FINAL:" -ForegroundColor Blue
docker-compose ps

# 13. Verificar se Evolution está funcionando
Write-Host "`n🔍 TESTE FINAL DA API:" -ForegroundColor Blue
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/health" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ SUCESSO! Evolution API funcionando!" -ForegroundColor Green
    Write-Host "Health status: $health" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Evolution API ainda não respondeu" -ForegroundColor Red
    Write-Host "Aguarde mais alguns minutos ou verifique logs:" -ForegroundColor Yellow
    Write-Host "docker logs -f evolution_whatsapp" -ForegroundColor Gray
}

# 14. Informações finais
Write-Host "`n🎉 CORREÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs para testar:" -ForegroundColor Blue
Write-Host "Manager:  http://localhost:8080/manager" -ForegroundColor Cyan
Write-Host "Health:   http://localhost:8080/health" -ForegroundColor Cyan
Write-Host "Docs:     http://localhost:8080/docs" -ForegroundColor Cyan
Write-Host "N8N:      http://localhost:5678" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 API Key: evolution_123456" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Comandos úteis:" -ForegroundColor Blue
Write-Host "Ver status:    docker-compose ps" -ForegroundColor Gray
Write-Host "Ver logs:      docker logs -f evolution_whatsapp" -ForegroundColor Gray
Write-Host "Parar tudo:    docker-compose down" -ForegroundColor Gray
Write-Host "Iniciar tudo:  docker-compose up -d" -ForegroundColor Gray
Write-Host ""

# Verificar se algum container ainda está com problema
$problemContainers = docker ps -a --filter "status=restarting" --filter "status=exited" --format "{{.Names}}"
if ($problemContainers) {
    Write-Host "⚠️ CONTAINERS COM PROBLEMA:" -ForegroundColor Yellow
    Write-Host $problemContainers -ForegroundColor Red
    Write-Host "Execute: docker logs <nome_do_container>" -ForegroundColor Gray
} else {
    Write-Host "✅ TODOS OS CONTAINERS OK!" -ForegroundColor Green
}

Write-Host ""
Read-Host "Pressione Enter para finalizar"