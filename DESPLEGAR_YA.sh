#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# DEPLOYMENT SUPER SIMPLE - SOLO EJECUTAR ESTE SCRIPT
# ═══════════════════════════════════════════════════════════════

echo "🚀 DESPLEGANDO STREAMMASTER PRO..."
echo ""

# 1. Parar TODO
echo "⏸️  Deteniendo todos los contenedores..."
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# 2. Limpiar
echo "🧹 Limpiando..."
docker system prune -f

# 3. Ir al directorio correcto
cd /docker/streammaster-pro || mkdir -p /docker/streammaster-pro
cd /docker/streammaster-pro

# 3.1 FORZAR ACTUALIZACIÓN (CRÍTICO PARA ARREGLAR PROBLEMAS)
echo "🔄 Sincronizando código..."
if [ ! -d ".git" ]; then
    echo "⚠️ No detectado repositorio, clonando de nuevo..."
    cd ..
    rm -rf streammaster-pro
    # Clonamos el repositorio correcto
    git clone https://github.com/merchandev/streammaster-pro_22.git streammaster-pro
    cd streammaster-pro
fi

git fetch --all
git reset --hard origin/main
git pull origin main

# 3.2 ARREGLAR PERMISOS (CRÍTICO PARA ERROR 403)
echo "🔑 Arreglando permisos..."
chmod -R 755 frontend
chmod 644 frontend/*

# 4. Desplegar
echo "🚀 Desplegando..."
docker-compose up -d --build

# 5. Esperar
echo "⏳ Esperando 20 segundos..."
sleep 20

# 6. Ver estado
echo ""
echo "📊 ESTADO:"
docker ps

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ LISTO"
echo ""
echo "OBS:"
echo "  Servidor: rtmp://72.62.86.94:1935/live"
echo "  Clave: mistream"
echo ""
echo "VER STREAM:"
echo "  http://72.62.86.94/"
echo ""
echo "═══════════════════════════════════════════════════════════════"
