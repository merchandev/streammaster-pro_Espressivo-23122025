#!/bin/bash

echo "========================================"
echo "🔧 StreamMaster Pro - Fix Web Service"
echo "========================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar que los archivos frontend existen
echo "📁 Verificando archivos del frontend..."
if [ ! -f ./frontend/index.html ]; then
    echo -e "${RED}❌ ERROR: No se encuentra ./frontend/index.html${NC}"
    exit 1
fi

if [ ! -f ./frontend/player.html ]; then
    echo -e "${RED}❌ ERROR: No se encuentra ./frontend/player.html${NC}"
    exit 1
fi

if [ ! -f ./frontend/style.css ]; then
    echo -e "${RED}❌ ERROR: No se encuentra ./frontend/style.css${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archivos del frontend encontrados${NC}"
echo ""

# 2. Detener el contenedor web
echo "🛑 Deteniendo contenedor streammaster-web..."
docker stop streammaster-web 2>/dev/null || true
docker rm streammaster-web 2>/dev/null || true
echo -e "${GREEN}✅ Contenedor detenido${NC}"
echo ""

# 3. Limpiar volúmenes huérfanos
echo "🧹 Limpiando volúmenes no utilizados..."
docker volume prune -f
echo ""

# 4. Reininiciar el servicio web
echo "🚀 Iniciando servicio web..."
docker-compose up -d web
echo ""

# 5. Esperar a que el contenedor esté listo
echo "⏳ Esperando que el contenedor esté listo..."
sleep 3
echo ""

# 6. Verificar que el contenedor está ejecutándose
echo "🔍 Verificando estado del contenedor..."
if docker ps | grep -q streammaster-web; then
    echo -e "${GREEN}✅ Contenedor streammaster-web está ejecutándose${NC}"
else
    echo -e "${RED}❌ ERROR: El contenedor no está ejecutándose${NC}"
    echo "Logs del contenedor:"
    docker logs streammaster-web --tail 50
    exit 1
fi
echo ""

# 7. Verificar archivos dentro del contenedor
echo "📂 Verificando archivos dentro del contenedor..."
echo "Contenido de /usr/share/nginx/html/:"
docker exec streammaster-web ls -lah /usr/share/nginx/html/
echo ""

# 8. Verificar permisos
echo "🔐 Verificando permisos..."
docker exec streammaster-web ls -la /usr/share/nginx/html/
echo ""

# 9. Probar conexión local
echo "🌐 Probando conexión HTTP..."
response=$(docker exec streammaster-web wget -O- http://localhost 2>&1 | head -n 1)
if echo "$response" | grep -q "200 OK\|HTML"; then
    echo -e "${GREEN}✅ Nginx responde correctamente dentro del contenedor${NC}"
else
    echo -e "${YELLOW}⚠️  Respuesta: $response${NC}"
fi
echo ""

# 10. Mostrar logs recientes
echo "📋 Logs recientes del contenedor:"
docker logs streammaster-web --tail 20
echo ""

# 11. Mostrar configuración de red
echo "🌐 Configuración de puertos:"
docker port streammaster-web
echo ""

echo "========================================"
echo -e "${GREEN}✅ Proceso completado${NC}"
echo "========================================"
echo ""
echo "🔍 Verifica ahora:"
echo "   • Accede a http://72.62.86.94 en tu navegador"
echo "   • O usa: curl -I http://72.62.86.94"
echo ""
echo "Si aún tienes problemas, verifica:"
echo "   1. El firewall permite el puerto 80"
echo "   2. No hay otro servicio usando el puerto 80"
echo "   3. Los archivos en ./frontend son accesibles"
echo ""
