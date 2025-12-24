#!/bin/bash

# ===================================================
# StreamMaster Pro - Script de Despliegue Automatizado
# Versión 2.0 - Sin API
# ===================================================

set -e  # Salir si hay errores

echo "🚀 StreamMaster Pro - Despliegue Automatizado"
echo "=============================================="
echo ""

# Variables
PROJECT_DIR="/docker/streammaster-pro"
COMPOSE_FILE="docker-compose.hostinger.yml"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funciones
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 1. Verificar que estamos en el directorio correcto
print_info "Verificando directorio..."
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Directorio $PROJECT_DIR no encontrado"
    exit 1
fi

cd "$PROJECT_DIR"
print_success "Directorio correcto: $PROJECT_DIR"

# 2. Actualizar código desde Git
print_info "Actualizando código desde Git..."
if git pull origin main; then
    print_success "Código actualizado"
else
    print_error "Error al actualizar código"
    exit 1
fi

# 3. Verificar archivos del frontend
print_info "Verificando archivos del frontend..."
    exit 1
fi

if [ ! -f "nginx/stat.xsl" ]; then
    print_error "nginx/stat.xsl no encontrado"
    exit 1
fi

print_success "Todos los archivos del frontend y Nginx están presentes"

if [ ! -f "frontend/player.html" ]; then
    print_error "frontend/player.html no encontrado"
    exit 1
fi

if [ ! -f "frontend/style.css" ]; then
    print_error "frontend/style.css no encontrado"
    exit 1
fi

# Verificar archivos de Nginx
if [ ! -f "nginx/web.conf" ]; then
    print_error "nginx/web.conf no encontrado"
    exit 1
fi

if [ ! -f "nginx/stat.xsl" ]; then
    print_error "nginx/stat.xsl no encontrado"
    exit 1
fi

print_success "Todos los archivos necesarios están presentes"

# 4. Establecer permisos correctos
print_info "Configurando permisos..."
chmod -R 755 frontend/
chmod -R 755 nginx/
print_success "Permisos configurados"

# 5. Detener servicios actuales
print_info "Deteniendo servicios actuales..."
docker-compose -f $COMPOSE_FILE down
print_success "Servicios detenidos"

# 6. Limpiar volúmenes antiguos (opcional)
read -p "¿Desea limpiar volúmenes antiguos? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_info "Limpiando volúmenes..."
    docker-compose -f $COMPOSE_FILE down -v
    print_success "Volúmenes limpiados"
fi

# 7. Crear directorios necesarios
print_info "Creando directorios para streams y logs..."
mkdir -p data/streams/hls
mkdir -p logs/nginx
chmod -R 777 data/
chmod -R 777 logs/
print_success "Directorios creados"

# 8. Reconstruir e iniciar servicios
print_info "Reconstruyendo e iniciando servicios..."
if docker-compose -f $COMPOSE_FILE up -d --build; then
    print_success "Servicios iniciados"
else
    print_error "Error al iniciar servicios"
    exit 1
fi

# 9. Esperar que los servicios inicien
print_info "Esperando que los servicios inicien (10 segundos)..."
sleep 10

# 10. Verificar estado de los servicios
print_info "Estado de los servicios:"
docker-compose -f $COMPOSE_FILE ps

# 11. Verificar que los contenedores estén corriendo
if docker-compose -f $COMPOSE_FILE ps | grep -q "Up"; then
    print_success "Servicios corriendo correctamente"
else
    print_error "Algunos servicios no están corriendo"
    print_info "Ver logs con: docker-compose -f $COMPOSE_FILE logs"
    exit 1
fi

# 12. Verificar acceso web
print_info "Verificando acceso web..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    print_success "Puerto 80 accesible"
else
    print_error "Puerto 80 no accesible (puede ser 403 si no hay index configurado)"
fi

# 13. Verificar servicio RTMP
print_info "Verificando servicio RTMP..."
if curl -s http://localhost:8080/stat > /dev/null; then
    print_success "Servicio RTMP responde"
else
    print_error "Servicio RTMP no responde"
fi

# 14. Configurar firewall
print_info "Verificando firewall..."
if command -v ufw &> /dev/null; then
    print_info "Configurando reglas de firewall..."
    ufw allow 80/tcp
    ufw allow 1935/tcp
    ufw allow 8080/tcp
    print_success "Firewall configurado"
else
    print_info "UFW no encontrado, saltando configuración de firewall"
fi

# 15. Mostrar información final
echo ""
echo "=============================================="
print_success "DESPLIEGUE COMPLETADO"
echo "=============================================="
echo ""
echo "📡 URLs de Acceso:"
echo "   - Página Principal: http://72.62.86.94"
echo "   - Player: http://72.62.86.94/player.html"
echo "   - Estadísticas RTMP: http://72.62.86.94:8080/stat"
echo ""
echo "🎥 Configuración OBS/vMix:"
echo "   - Servidor RTMP: rtmp://72.62.86.94:1935/live"
echo "   - Stream Key: M0nagas_Live_Secure_2025"
echo ""
echo "📊 Comandos útiles:"
echo "   - Ver logs: docker-compose -f $COMPOSE_FILE logs -f"
echo "   - Ver estado: docker-compose -f $COMPOSE_FILE ps"
echo "   - Reiniciar: docker-compose -f $COMPOSE_FILE restart"
echo ""

# 16. Preguntar si mostrar logs
read -p "¿Desea ver los logs en tiempo real? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    docker-compose -f $COMPOSE_FILE logs -f
fi
