#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════
# 🚀 MIGRACIÓN A STREAMING ÚNICO - StreamMaster Pro
# ════════════════════════════════════════════════════════════════════════════
# Este script migra de la configuración antigua (4 contenedores + tokens)
# a la configuración simplificada (2 contenedores + streaming fijo)
# ════════════════════════════════════════════════════════════════════════════

set -e  # Salir si hay cualquier error

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   🚀 MIGRACIÓN A STREAMING ÚNICO - StreamMaster Pro${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 1: Verificación del directorio
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}📁 Paso 1: Verificando directorio...${NC}"

if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: No se encuentra docker-compose.yml${NC}"
    echo "   Ejecuta este script desde: /docker/streammaster-pro"
    exit 1
fi

echo -e "${GREEN}✅ Directorio correcto:${NC} $(pwd)"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 2: Backup de la configuración actual
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}💾 Paso 2: Creando backup...${NC}"

BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup de docker-compose
if [ -f "docker-compose.hostinger.yml" ]; then
    cp docker-compose.hostinger.yml "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup de docker-compose.hostinger.yml${NC}"
fi

# Backup de frontend
if [ -d "frontend" ]; then
    cp -r frontend "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup de frontend/${NC}"
fi

echo -e "${YELLOW}   Backup guardado en:${NC} $BACKUP_DIR"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 3: Detener servicios antiguos
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}⏸️  Paso 3: Deteniendo servicios antiguos...${NC}"

# Contar contenedores antes
BEFORE=$(docker ps -a | grep streammaster | wc -l)
echo -e "   Contenedores encontrados: ${YELLOW}$BEFORE${NC}"

# Detener con docker-compose
docker-compose -f docker-compose.hostinger.yml down -v 2>/dev/null || true

# Asegurarse de que todo está detenido
docker stop $(docker ps -aq 2>/dev/null) 2>/dev/null || true
docker rm $(docker ps -aq 2>/dev/null) 2>/dev/null || true

echo -e "${GREEN}✅ Servicios detenidos${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 4: Limpiar imágenes antiguas
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}🧹 Paso 4: Limpiando imágenes antiguas...${NC}"

# Limpiar imágenes no usadas
CLEANED=$(docker image prune -a -f 2>&1 | grep "Total reclaimed space" || echo "0B")
echo -e "${GREEN}✅ Imágenes limpiadas:${NC} $CLEANED"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 5: Verificar configuración
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}🔍 Paso 5: Verificando configuración nueva...${NC}"

# Contar servicios en docker-compose
SERVICES=$(grep "container_name:" docker-compose.hostinger.yml | wc -l)

if [ "$SERVICES" -eq 2 ]; then
    echo -e "${GREEN}✅ Configuración correcta: $SERVICES servicios (rtmp-server + web)${NC}"
elif [ "$SERVICES" -eq 4 ]; then
    echo -e "${RED}❌ ERROR: Configuración ANTIGUA detectada: $SERVICES servicios${NC}"
    echo -e "${YELLOW}   El archivo docker-compose.hostinger.yml no fue actualizado${NC}"
    echo ""
    echo -e "${YELLOW}   Opciones:${NC}"
    echo "   1. Actualizar desde Git: git pull origin main"
    echo "   2. Copiar manualmente el archivo correcto"
    echo "   3. Restaurar backup y actualizar: cp $BACKUP_DIR/docker-compose.hostinger.yml ."
    exit 1
else
    echo -e "${YELLOW}⚠️  Advertencia: Número inusual de servicios: $SERVICES${NC}"
    echo -e "${YELLOW}   Continuando de todas formas...${NC}"
fi

# Verificar que NO existan servicios de api y redis
if grep -q "container_name: streammaster-api" docker-compose.hostinger.yml; then
    echo -e "${RED}❌ ERROR: Todavía existe servicioapi en docker-compose${NC}"
    exit 1
fi

if grep -q "container_name: streammaster-redis" docker-compose.hostinger.yml; then
    echo -e "${RED}❌ ERROR: Todavía existe servicio redis en docker-compose${NC}"
    exit 1
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 6: Verificar archivos del frontend
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}📂 Paso 6: Verificando archivos del frontend...${NC}"

if [ ! -f "frontend/index.html" ]; then
    echo -e "${YELLOW}⚠️  frontend/index.html no existe${NC}"
fi

if [ ! -f "frontend/player.html" ]; then
    echo -e "${RED}❌ ERROR: frontend/player.html no existe${NC}"
    exit 1
fi

# Verificar que player.html tenga stream fijo
if grep -q "const streamId = 'mistream'" frontend/player.html; then
    echo -e "${GREEN}✅ player.html tiene stream fijo configurado${NC}"
else
    echo -e "${YELLOW}⚠️  player.html podría no tener stream fijo${NC}"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 7: Construir e iniciar servicios
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}🔨 Paso 7: Construyendo e iniciando servicios...${NC}"
echo -e "${YELLOW}   (Esto puede tardar 1-2 minutos)${NC}"
echo ""

docker-compose -f docker-compose.hostinger.yml up -d --build

echo -e "${GREEN}✅ Servicios iniciados${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 8: Esperar que los servicios inicien
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}⏳ Paso 8: Esperando que los servicios inicien...${NC}"

for i in {1..15}; do
    echo -n "."
    sleep 1
done
echo ""
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 9: Verificar estado final
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${BLUE}📊 Paso 9: Verificando estado final...${NC}"
echo ""

# Estado de contenedores
docker-compose -f docker-compose.hostinger.yml ps

echo ""

# Contar contenedores corriendo
RUNNING=$(docker ps | grep streammaster | wc -l)

if [ "$RUNNING" -eq 2 ]; then
    echo -e "${GREEN}✅ Todos los contenedores están corriendo (2/2)${NC}"
else
    echo -e "${RED}❌ Solo $RUNNING/2 contenedores están corriendo${NC}"
    echo -e "${YELLOW}   Ver logs para más detalles:${NC}"
    echo "   docker logs streammaster-rtmp"
    echo "   docker logs streammaster-web"
fi

# Verificar puertos
echo ""
echo -e "${BLUE}Verificando puertos:${NC}"

check_port() {
    PORT=$1
    NAME=$2
    if netstat -tulpn 2>/dev/null | grep -q ":$PORT " || ss -tulpn 2>/dev/null | grep -q ":$PORT "; then
        echo -e "${GREEN}✅ Puerto $PORT ($NAME)${NC}"
    else
        echo -e "${RED}❌ Puerto $PORT ($NAME) NO está abierto${NC}"
    fi
}

check_port 1935 "RTMP"
check_port 8080 "HLS"
check_port 80 "Web"

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Paso 10: Información final
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "TU_IP_AQUI")

echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   ✅ MIGRACIÓN COMPLETADA EXITOSAMENTE${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📡 Configuración OBS (Permanente):${NC}"
echo ""
echo "   Servicio: Personalizado"
echo "   Servidor: rtmp://$SERVER_IP:1935/live"
echo "   Clave de Stream: mistream"
echo ""
echo -e "${BLUE}🌐 Ver Streaming:${NC}"
echo ""
echo "   http://$SERVER_IP/"
echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}📋 Próximos Pasos:${NC}"
echo ""
echo "   1. Configurar OBS con los datos de arriba"
echo "   2. Iniciar transmisión en OBS"
echo "   3. Esperar 10-15 segundos"
echo "   4. Abrir el player en: http://$SERVER_IP/"
echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}🔧 Comandos Útiles:${NC}"
echo ""
echo "   Ver logs en tiempo real:"
echo "   docker logs streammaster-rtmp -f"
echo ""
echo "   Ver estado:"
echo "   docker-compose -f docker-compose.hostinger.yml ps"
echo ""
echo "   Reiniciar servicios:"
echo "   docker-compose -f docker-compose.hostinger.yml restart"
echo ""
echo "   Diagnóstico completo:"
echo "   ./diagnostico.sh"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
