#!/bin/bash

echo "================================================"
echo "🚀 StreamMaster Pro - Despliegue Completo"
echo "================================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# PASO 1: Verificar archivos necesarios
# ============================================
echo -e "${BLUE}📋 PASO 1: Verificando archivos necesarios...${NC}"
required_files=(
    "./docker-compose.yml"
    "./frontend/index.html"
    "./frontend/player.html"
    "./frontend/style.css"
    "./nginx/web.conf"
    "./nginx/nginx.conf"
    "./nginx/Dockerfile"
    "./nginx/stat.xsl"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ ERROR: No se encuentra $file${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✅ Todos los archivos necesarios existen${NC}"
echo ""

# ============================================
# PASO 2: Detener servicios existentes
# ============================================
echo -e "${BLUE}🛑 PASO 2: Deteniendo servicios existentes...${NC}"
docker-compose down -v
echo -e "${GREEN}✅ Servicios detenidos${NC}"
echo ""

# ============================================
# PASO 3: Limpiar contenedores y volúmenes
# ============================================
echo -e "${BLUE}🧹 PASO 3: Limpiando contenedores y volúmenes...${NC}"
docker system prune -f
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo ""

# ============================================
# PASO 4: Crear directorios necesarios
# ============================================
echo -e "${BLUE}📁 PASO 4: Creando directorios necesarios...${NC}"
mkdir -p data/streams
mkdir -p logs/nginx
chmod -R 755 data logs
echo -e "${GREEN}✅ Directorios creados${NC}"
echo ""

# ============================================
# PASO 5: Construir imágenes
# ============================================
echo -e "${BLUE}🔨 PASO 5: Construyendo imágenes Docker...${NC}"
docker-compose build --no-cache
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ERROR: Falló la construcción de imágenes${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Imágenes construidas${NC}"
echo ""

# ============================================
# PASO 6: Iniciar servicios
# ============================================
echo -e "${BLUE}🚀 PASO 6: Iniciando servicios...${NC}"
docker-compose up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ERROR: Falló el inicio de servicios${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Servicios iniciados${NC}"
echo ""

# ============================================
# PASO 7: Esperar a que los servicios estén listos
# ============================================
echo -e "${BLUE}⏳ PASO 7: Esperando a que los servicios estén listos...${NC}"
sleep 5
echo -e "${GREEN}✅ Servicios listos${NC}"
echo ""

# ============================================
# PASO 8: Verificar estado de contenedores
# ============================================
echo -e "${BLUE}🔍 PASO 8: Verificando estado de contenedores...${NC}"
echo ""
docker-compose ps
echo ""

# Verificar que ambos contenedores están running
if ! docker ps | grep -q streammaster-rtmp; then
    echo -e "${RED}❌ ERROR: streammaster-rtmp no está ejecutándose${NC}"
    echo "Logs:"
    docker logs streammaster-rtmp --tail 50
    exit 1
fi

if ! docker ps | grep -q streammaster-web; then
    echo -e "${RED}❌ ERROR: streammaster-web no está ejecutándose${NC}"
    echo "Logs:"
    docker logs streammaster-web --tail 50
    exit 1
fi
echo -e "${GREEN}✅ Todos los contenedores están ejecutándose${NC}"
echo ""

# ============================================
# PASO 9: Verificar archivos en el contenedor web
# ============================================
echo -e "${BLUE}📂 PASO 9: Verificando archivos en el contenedor web...${NC}"
echo "Contenido de /usr/share/nginx/html/:"
docker exec streammaster-web ls -lah /usr/share/nginx/html/
echo ""

# Verificar que index.html existe
if docker exec streammaster-web test -f /usr/share/nginx/html/index.html; then
    echo -e "${GREEN}✅ index.html encontrado en el contenedor${NC}"
else
    echo -e "${RED}❌ ERROR: index.html NO encontrado en el contenedor${NC}"
    exit 1
fi
echo ""

# ============================================
# PASO 10: Verificar configuración nginx
# ============================================
echo -e "${BLUE}⚙️  PASO 10: Verificando configuración nginx...${NC}"
echo "Configuración de nginx:"
docker exec streammaster-web cat /etc/nginx/conf.d/default.conf
echo ""

# Test de configuración nginx
docker exec streammaster-web nginx -t
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuración de nginx válida${NC}"
else
    echo -e "${RED}❌ ERROR: Configuración de nginx inválida${NC}"
    exit 1
fi
echo ""

# ============================================
# PASO 11: Probar conectividad HTTP
# ============================================
echo -e "${BLUE}🌐 PASO 11: Probando conectividad HTTP...${NC}"

# Test interno
echo "Test interno (desde el contenedor):"
if docker exec streammaster-web wget -O /dev/null -q http://localhost; then
    echo -e "${GREEN}✅ HTTP funciona internamente${NC}"
else
    echo -e "${RED}❌ ERROR: HTTP no funciona internamente${NC}"
    docker logs streammaster-web --tail 30
    exit 1
fi

# Test externo (si curl está disponible)
if command -v curl &> /dev/null; then
    echo ""
    echo "Test externo (desde el host):"
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>&1)
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✅ HTTP responde con código 200${NC}"
    else
        echo -e "${YELLOW}⚠️  HTTP responde con código: $response${NC}"
    fi
fi
echo ""

# ============================================
# PASO 12: Mostrar logs recientes
# ============================================
echo -e "${BLUE}📋 PASO 12: Logs recientes...${NC}"
echo ""
echo "=== Logs streammaster-web ==="
docker logs streammaster-web --tail 15
echo ""
echo "=== Logs streammaster-rtmp ==="
docker logs streammaster-rtmp --tail 15
echo ""

# ============================================
# PASO 13: Información de puertos
# ============================================
echo -e "${BLUE}🔌 PASO 13: Puertos expuestos...${NC}"
echo ""
echo "streammaster-web:"
docker port streammaster-web
echo ""
echo "streammaster-rtmp:"
docker port streammaster-rtmp
echo ""

# ============================================
# RESUMEN FINAL
# ============================================
echo "================================================"
echo -e "${GREEN}✅ DESPLIEGUE COMPLETADO EXITOSAMENTE${NC}"
echo "================================================"
echo ""
echo -e "${YELLOW}📌 INFORMACIÓN IMPORTANTE:${NC}"
echo ""
echo "🌐 Panel Web:"
echo "   http://72.62.86.94"
echo "   http://localhost (desde el servidor)"
echo ""
echo "📺 Player:"
echo "   http://72.62.86.94/player.html"
echo ""
echo "📡 Servidor RTMP:"
echo "   URL: rtmp://72.62.86.94:1935/live"
echo "   Key: mistream"
echo ""
echo "🎥 Stream HLS:"
echo "   http://72.62.86.94:8080/hls/mistream.m3u8"
echo ""
echo -e "${YELLOW}🔍 PRÓXIMOS PASOS:${NC}"
echo ""
echo "1. Verifica el panel web:"
echo "   curl -I http://72.62.86.94"
echo ""
echo "2. Configura tu encoder (OBS/vMix):"
echo "   • Servidor: rtmp://72.62.86.94:1935/live"
echo "   • Clave: mistream"
echo ""
echo "3. Monitorea los logs:"
echo "   docker-compose logs -f"
echo ""
echo "4. Si hay problemas con el puerto 80:"
echo "   sudo ufw allow 80/tcp"
echo "   sudo ufw reload"
echo ""
echo "================================================"
