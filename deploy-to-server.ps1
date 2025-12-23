# ================================================
# Script de Despliegue a Servidor - StreamMaster Pro
# ================================================

$SERVER = "root@72.62.86.94"
$REMOTE_PATH = "/docker/streammaster-pro"
$LOCAL_PATH = "."

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 StreamMaster Pro - Deploy to Server" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# PASO 1: Verificar archivos locales
# ============================================
Write-Host "📋 PASO 1: Verificando archivos locales..." -ForegroundColor Blue

$required_files = @(
    "docker-compose.yml",
    "nginx/web.conf",
    "nginx/nginx.conf",
    "nginx/Dockerfile",
    "nginx/stat.xsl",
    "fix-web.sh",
    "deploy-fix.sh",
    "frontend/index.html",
    "frontend/player.html",
    "frontend/style.css"
)

$missing_files = @()
foreach ($file in $required_files) {
    if (-not (Test-Path $file)) {
        $missing_files += $file
    }
}

if ($missing_files.Count -gt 0) {
    Write-Host "❌ ERROR: Faltan archivos:" -ForegroundColor Red
    foreach ($file in $missing_files) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    exit 1
}

Write-Host "✅ Todos los archivos necesarios existen" -ForegroundColor Green
Write-Host ""

# ============================================
# PASO 2: Copiar archivos al servidor
# ============================================
Write-Host "📤 PASO 2: Copiando archivos al servidor..." -ForegroundColor Blue
Write-Host "Servidor: $SERVER" -ForegroundColor Yellow
Write-Host "Ruta remota: $REMOTE_PATH" -ForegroundColor Yellow
Write-Host ""

# Opción A: Si tienes Git en el servidor (recomendado)
Write-Host "¿Quieres usar Git para actualizar? (S/N)" -ForegroundColor Yellow
$useGit = Read-Host

if ($useGit -eq "S" -or $useGit -eq "s") {
    Write-Host ""
    Write-Host "📥 Usando Git para actualizar el servidor..." -ForegroundColor Blue
    Write-Host ""
    Write-Host "Ejecuta estos comandos EN EL SERVIDOR:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ssh $SERVER" -ForegroundColor Cyan
    Write-Host "cd $REMOTE_PATH" -ForegroundColor Cyan
    Write-Host "git pull" -ForegroundColor Cyan
    Write-Host "chmod +x deploy-fix.sh fix-web.sh" -ForegroundColor Cyan
    Write-Host "./deploy-fix.sh" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Presiona ENTER cuando hayas terminado..."
    Read-Host
}
else {
    Write-Host ""
    Write-Host "📤 Copiando archivos con SCP..." -ForegroundColor Blue
    
    # 1. Crear directorios remotos
    Write-Host "Creando estructura de directorios..." -ForegroundColor Gray
    ssh $SERVER "mkdir -p $REMOTE_PATH/nginx $REMOTE_PATH/frontend $REMOTE_PATH/logs/nginx $REMOTE_PATH/data/streams"

    # 2. Copiar archivos raíz
    $root_files = @(
        "docker-compose.yml", 
        "fix-web.sh", 
        "deploy-fix.sh", 
        "TROUBLESHOOTING.md", 
        "SOLUCION_403.md",
        "README.md"
    )

    foreach ($file in $root_files) {
        if (Test-Path $file) {
            Write-Host "Copiando $file..." -ForegroundColor Gray
            scp $file "${SERVER}:${REMOTE_PATH}/"
        }
    }

    # 3. Copiar directorios completos (recursivo)
    Write-Host "Copiando directorio nginx/..." -ForegroundColor Gray
    scp -r nginx/ "${SERVER}:${REMOTE_PATH}/"

    Write-Host "Copiando directorio frontend/..." -ForegroundColor Gray
    scp -r frontend/ "${SERVER}:${REMOTE_PATH}/"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Archivos copiados correctamente" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Hubo errores en la copia" -ForegroundColor Red
    }
    Write-Host ""
}

# ============================================
# PASO 3: Ejecutar despliegue en el servidor
# ============================================
Write-Host "🚀 PASO 3: Ejecutar despliegue en el servidor" -ForegroundColor Blue
Write-Host ""
Write-Host "Ahora voy a conectarte al servidor para ejecutar el script..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona ENTER para continuar..."
Read-Host

# Construir comando SSH para ejecutar el script
$ssh_commands = @"
cd $REMOTE_PATH && \
chmod +x deploy-fix.sh && \
./deploy-fix.sh
"@

Write-Host "Ejecutando: ssh $SERVER '$ssh_commands'" -ForegroundColor Gray
Write-Host ""

ssh $SERVER $ssh_commands

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Proceso completado" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔍 Verifica ahora:" -ForegroundColor Yellow
Write-Host "   • Panel: http://72.62.86.94" -ForegroundColor White
Write-Host "   • Player: http://72.62.86.94/player.html" -ForegroundColor White
Write-Host ""
