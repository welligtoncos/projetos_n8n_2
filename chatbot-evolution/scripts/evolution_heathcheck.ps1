# Health Check Evolution API
Write-Host "🔍 Evolution API - Health Check" -ForegroundColor Blue
Write-Host "===============================" -ForegroundColor Blue
Write-Host ""

$overallStatus = $true

# 1. Verificar container Evolution
Write-Host "🧱 Verificando container evolution_whatsapp..." -ForegroundColor Yellow
$evolutionContainer = docker ps --filter "name=evolution_whatsapp" --filter "status=running" --quiet
if ($evolutionContainer) {
    Write-Host "✅ Container Evolution API está rodando." -ForegroundColor Green
} else {
    Write-Host "❌ Container Evolution API NÃO está rodando!" -ForegroundColor Red
    $overallStatus = $false
}

Write-Host ""

# 2. Verificar PostgreSQL
Write-Host "🗄️ Testando PostgreSQL..." -ForegroundColor Yellow
try {
    $pgCheck = docker exec evolution_postgres pg_isready -U evolution 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL OK." -ForegroundColor Green
    } else {
        Write-Host "❌ Problema na conexão com PostgreSQL." -ForegroundColor Red
        $overallStatus = $false
    }
} catch {
    Write-Host "❌ Erro ao verificar PostgreSQL." -ForegroundColor Red
    $overallStatus = $false
}

Write-Host ""

# 3. Verificar Chromium
Write-Host "🌐 Verificando Chromium..." -ForegroundColor Yellow
try {
    $chromiumCheck = docker exec evolution_whatsapp which chromium 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Chromium encontrado." -ForegroundColor Green
    } else {
        Write-Host "❌ Chromium NÃO encontrado." -ForegroundColor Red
        $overallStatus = $false
    }
} catch {
    Write-Host "❌ Erro ao verificar Chromium." -ForegroundColor Red
    $overallStatus = $false
}

Write-Host ""

# 4. Testar API Health
Write-Host "🌐 Testando API Evolution /health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get -TimeoutSec 10 -ErrorAction Stop
    if ($healthResponse -match "UP|OK" -or $healthResponse.status -eq "UP") {
        Write-Host "✅ API Evolution respondendo /health." -ForegroundColor Green
    } else {
        Write-Host "❌ API Evolution não respondeu adequadamente ao /health." -ForegroundColor Red
        $overallStatus = $false
    }
} catch {
    Write-Host "❌ API Evolution não respondeu ao /health." -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Gray
    $overallStatus = $false
}

Write-Host ""

# 5. Verificar instâncias
Write-Host "📲 Verificando instâncias WhatsApp..." -ForegroundColor Yellow
try {
    $headers = @{ "apikey" = "evolution_123456" }
    $instancesResponse = Invoke-RestMethod -Uri "http://localhost:8080/instance/fetchInstances" -Method Get -Headers $headers -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ Conseguiu listar instâncias." -ForegroundColor Green
    
    if ($instancesResponse -and $instancesResponse.Count -gt 0) {
        Write-Host "📊 Instâncias encontradas: $($instancesResponse.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ Nenhuma instância encontrada." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Não conseguiu verificar instâncias." -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Gray
    $overallStatus = $false
}

Write-Host ""

# 6. Verificar uso de recursos
Write-Host "💾 Verificando recursos..." -ForegroundColor Yellow
try {
    $dockerStats = docker stats evolution_whatsapp --no-stream --format "{{.MemPerc}}" 2>$null
    if ($dockerStats) {
        $memUsage = $dockerStats.Replace('%', '')
        Write-Host "📊 Uso de memória: $memUsage%" -ForegroundColor Cyan
        if ([int]$memUsage -gt 80) {
            Write-Host "⚠️ Alto uso de memória!" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "⚠️ Não foi possível verificar recursos." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================" -ForegroundColor Blue

# Status final
if ($overallStatus) {
    Write-Host "✅ Health Check APROVADO - Sistema operacional" -ForegroundColor Green
} else {
    Write-Host "❌ Health Check FALHOU - Verificar problemas acima" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 Para mais detalhes:" -ForegroundColor Blue
Write-Host "docker-compose ps" -ForegroundColor Gray
Write-Host "docker logs evolution_whatsapp" -ForegroundColor Gray

Write-Host ""
Read-Host "Pressione Enter para continuar"