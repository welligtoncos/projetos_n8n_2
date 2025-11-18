Write-Host "=== INICIALIZACAO CHATBOT EVOLUTION ===" -ForegroundColor Blue

Write-Host "Verificando Docker..." -ForegroundColor Yellow
docker --version

Write-Host "Parando containers..." -ForegroundColor Yellow  
docker-compose down

Write-Host "Baixando imagens..." -ForegroundColor Yellow
docker pull ghcr.io/atendai/evolution-api:2.2.2

Write-Host "Iniciando..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "Aguardando..." -ForegroundColor Yellow
Start-Sleep 30

Write-Host "Status:" -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "PRONTO! Acesse: http://localhost:8080/manager" -ForegroundColor Green
Write-Host "API Key: evolution_123456" -ForegroundColor Yellow

Read-Host "Pressione Enter"
