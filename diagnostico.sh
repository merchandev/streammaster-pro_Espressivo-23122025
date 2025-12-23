#!/bin/bash

# 🔍 Script de Diagnóstico - StreamMaster Pro
# Muestra errores y estado completo del sistema

echo "════════════════════════════════════════════════════════════"
echo "🔍 DIAGNÓSTICO STREAMMASTER PRO"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.hostinger.yml" ]; then
    echo -e "${RED}❌ Error: No se encuentra docker-compose.hostinger.yml${NC}"
    echo "   Ejecuta este script desde: /docker/streammaster-pro"
    exit 1
fi

echo -e "${BLUE}📁 Directorio actual:${NC} $(pwd)"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 1. ESTADO DE LOS CONTENEDORES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker-compose -f docker-compose.hostinger.yml ps

RUNNING_CONTAINERS=$(docker-compose -f docker-compose.hostinger.yml ps | grep "Up" | wc -l)
if [ "$RUNNING_CONTAINERS" -eq 2 ]; then
    echo -e "${GREEN}✅ Todos los contenedores están corriendo (2/2)${NC}"
else
    echo -e "${RED}❌ Algunos contenedores NO están corriendo${NC}"
    echo -e "${YELLOW}   Esperados: 2 (rtmp-server + web)${NC}"
    echo -e "${YELLOW}   Corriendo: $RUNNING_CONTAINERS${NC}"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚨 2. ERRORES EN LOGS (Últimos 30 segundos)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo -e "${BLUE}📝 RTMP Server (nginx):${NC}"
echo "────────────────────────────────────────────────────────────"
RTMP_ERRORS=$(docker logs streammaster-rtmp --since 30s 2>&1 | grep -i "error\|emerg\|alert\|crit\|failed" || echo "Sin errores")
if [ "$RTMP_ERRORS" == "Sin errores" ]; then
    echo -e "${GREEN}✅ Sin errores en nginx${NC}"
else
    echo -e "${RED}$RTMP_ERRORS${NC}"
fi
echo ""

echo -e "${BLUE}📝 Web Server:${NC}"
echo "────────────────────────────────────────────────────────────"
WEB_ERRORS=$(docker logs streammaster-web --since 30s 2>&1 | grep -i "error\|emerg\|alert\|crit\|failed" || echo "Sin errores")
if [ "$WEB_ERRORS" == "Sin errores" ]; then
    echo -e "${GREEN}✅ Sin errores en web${NC}"
else
    echo -e "${RED}$WEB_ERRORS${NC}"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 3. VERIFICACIÓN DE PUERTOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_port() {
    PORT=$1
    NAME=$2
    if netstat -tulpn 2>/dev/null | grep -q ":$PORT "; then
        echo -e "${GREEN}✅ Puerto $PORT ($NAME) - ABIERTO${NC}"
    else
        echo -e "${RED}❌ Puerto $PORT ($NAME) - CERRADO${NC}"
    fi
}

check_port 1935 "RTMP"
check_port 8080 "HLS"
check_port 80 "Web"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📺 4. CONFIGURACIÓN DE NGINX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}🔍 Verificando hls_path:${NC}"
HLS_PATH=$(docker exec streammaster-rtmp cat /etc/nginx/nginx.conf 2>/dev/null | grep "hls_path" | head -1)
if echo "$HLS_PATH" | grep -q "/tmp/streams/hls"; then
    echo -e "${GREEN}✅ hls_path configurado correctamente:${NC} $HLS_PATH"
else
    echo -e "${RED}❌ hls_path INCORRECTO:${NC} $HLS_PATH"
    echo -e "${YELLOW}   Debe ser: hls_path /tmp/streams/hls;${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Verificando alias HLS:${NC}"
HLS_ALIAS=$(docker exec streammaster-rtmp cat /etc/nginx/nginx.conf 2>/dev/null | grep "alias /tmp" | head -1)
if echo "$HLS_ALIAS" | grep -q "/tmp/streams/hls"; then
    echo -e "${GREEN}✅ alias configurado correctamente:${NC} $HLS_ALIAS"
else
    echo -e "${RED}❌ alias INCORRECTO:${NC} $HLS_ALIAS"
    echo -e "${YELLOW}   Debe ser: alias /tmp/streams/hls;${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Test de configuración nginx:${NC}"
NGINX_TEST=$(docker exec streammaster-rtmp nginx -t 2>&1)
if echo "$NGINX_TEST" | grep -q "successful"; then
    echo -e "${GREEN}✅ Configuración nginx válida${NC}"
else
    echo -e "${RED}❌ Configuración nginx tiene errores:${NC}"
    echo "$NGINX_TEST"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 5. ARCHIVOS HLS (Streaming)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}🔍 Directorio HLS:${NC}"
HLS_DIR=$(docker exec streammaster-rtmp ls -la /tmp/streams/hls/ 2>&1)
if echo "$HLS_DIR" | grep -q "\.m3u8"; then
    echo -e "${GREEN}✅ Archivos HLS encontrados:${NC}"
    docker exec streammaster-rtmp ls -lh /tmp/streams/hls/ 2>/dev/null | grep -E "\.m3u8|\.ts"
else
    echo -e "${YELLOW}⚠️  No hay archivos HLS${NC}"
    echo "   Esto es normal si OBS no está transmitiendo"
    echo ""
    echo "   Contenido del directorio:"
    docker exec streammaster-rtmp ls -la /tmp/streams/hls/ 2>&1 || echo "   Directorio no existe"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 6. STREAMING ACTIVO (RTMP)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}🔍 Buscando conexiones RTMP activas:${NC}"
RTMP_ACTIVE=$(docker logs streammaster-rtmp --tail=50 2>&1 | grep -i "publishing\|connect" | tail -5)
if [ -z "$RTMP_ACTIVE" ]; then
    echo -e "${YELLOW}⚠️  No se detectan streams activos${NC}"
    echo "   OBS probablemente no está transmitiendo"
else
    echo -e "${GREEN}✅ Actividad RTMP detectada:${NC}"
    echo "$RTMP_ACTIVE"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 7. ACCESO WEB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}🔍 Probando acceso a player:${NC}"
WEB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
if [ "$WEB_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✅ Player accesible - HTTP $WEB_STATUS${NC}"
else
    echo -e "${RED}❌ Player NO accesible - HTTP $WEB_STATUS${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Probando acceso a HLS endpoint:${NC}"
HLS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/hls/ 2>/dev/null)
if [ "$HLS_STATUS" -eq 200 ] || [ "$HLS_STATUS" -eq 404 ]; then
    echo -e "${GREEN}✅ HLS endpoint accesible - HTTP $HLS_STATUS${NC}"
    if [ "$HLS_STATUS" -eq 404 ]; then
        echo -e "${YELLOW}   (404 es normal si no hay stream activo)${NC}"
    fi
else
    echo -e "${RED}❌ HLS endpoint NO accesible - HTTP $HLS_STATUS${NC}"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 8. USO DE RECURSOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | grep streammaster

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 9. ÚLTIMOS LOGS COMPLETOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo -e "${BLUE}🔷 RTMP Server (últimas 20 líneas):${NC}"
echo "────────────────────────────────────────────────────────────"
docker logs streammaster-rtmp --tail=20 2>&1
echo ""

echo -e "${BLUE}🔷 Web Server (últimas 10 líneas):${NC}"
echo "────────────────────────────────────────────────────────────"
docker logs streammaster-web --tail=10 2>&1
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 10. RESUMEN Y RECOMENDACIONES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Contar problemas
PROBLEMS=0

if [ "$RUNNING_CONTAINERS" -ne 2 ]; then
    echo -e "${RED}❌ Contenedores no están corriendo correctamente${NC}"
    ((PROBLEMS++))
fi

if ! echo "$HLS_PATH" | grep -q "/tmp/streams/hls"; then
    echo -e "${RED}❌ Configuración nginx incorrecta (hls_path)${NC}"
    ((PROBLEMS++))
fi

if ! netstat -tulpn 2>/dev/null | grep -q ":1935 "; then
    echo -e "${RED}❌ Puerto RTMP (1935) no está abierto${NC}"
    ((PROBLEMS++))
fi

if [ "$WEB_STATUS" -ne 200 ]; then
    echo -e "${RED}❌ Player web no está accesible${NC}"
    ((PROBLEMS++))
fi

echo ""
if [ "$PROBLEMS" -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡TODO ESTÁ FUNCIONANDO CORRECTAMENTE!${NC}"
    echo ""
    echo "Configuración OBS:"
    echo "  Servidor: rtmp://$(hostname -I | awk '{print $1}'):1935/live"
    echo "  Clave: mistream"
    echo ""
    echo "Ver streaming:"
    echo "  http://$(hostname -I | awk '{print $1}')/"
else
    echo -e "${RED}⚠️  SE ENCONTRARON $PROBLEMS PROBLEMA(S)${NC}"
    echo ""
    echo "Acciones recomendadas:"
    echo "  1. docker-compose -f docker-compose.hostinger.yml down"
    echo "  2. docker-compose -f docker-compose.hostinger.yml up -d --build"
    echo "  3. Ejecutar este script nuevamente"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Para ver logs en tiempo real:"
echo "  docker logs streammaster-rtmp -f"
echo ""
echo "Para reiniciar servicios:"
echo "  docker-compose -f docker-compose.hostinger.yml restart"
echo "════════════════════════════════════════════════════════════"
