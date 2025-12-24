#!/bin/bash

# ==========================================
# StreamMaster Pro - Habilitar HTTPS / SSL
# ==========================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔒 Configuración de SSL para StreamMaster Pro${NC}"
echo "=================================================="
echo ""

# 1. Configuración Integrada del Proyecto
DOMAIN="tv.monagasvision.com"
EMAIL="tv@monagasvision.com"
echo "Usando configuración integrada: $DOMAIN"

# 2. Sanitizar Input (Eliminar https://, http://, www. extra, y barras)
DOMAIN=$(echo "$DOMAIN" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
# Nota: NO eliminamos 'www.' automÃ¡ticamente porque quizÃ¡s el usuario SI quiere usar www.
EMAIL=$(echo "$EMAIL" | xargs) # Validar espacios

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: Dominio y Email son requeridos.${NC}"
    exit 1
fi

# Detectar comando Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_CMD="docker-compose"
else
    DOCKER_CMD="docker compose"
fi

echo ""
echo -e "Configurando SSL para: ${GREEN}$DOMAIN${NC}"
echo -e "Usando comando: ${GREEN}$DOCKER_CMD${NC}"
echo "Esto tomarÃ¡ unos minutos..."
echo ""

# 2. Asegurar que los directorios existen
mkdir -p ./data/certbot/conf
mkdir -p ./data/certbot/www

# 3. Iniciar Nginx
echo "Reiniciando servidor web para validaciÃ³n..."
# Limpiar contenedor previo
$DOCKER_CMD rm -f web >/dev/null 2>&1 || true
$DOCKER_CMD up -d web

echo "Esperando a que Nginx inicie..."
sleep 5

# 4. Solicitar Certificado
echo "Solicitando certificado a Let's Encrypt..."
$DOCKER_CMD run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    --email $EMAIL \
    -d $DOMAIN \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal" certbot

if [ $? -ne 0 ]; then
    echo -e "${RED}âŒ Error al obtener el certificado. Verifica que tu dominio apunte a este servidor.${NC}"
    echo -e "${RED}Dominio detectado: $DOMAIN${NC}"
    exit 1
fi

echo -e "${GREEN}âœ… Certificado obtenido correctamente.${NC}"

# 5. Configurar Nginx para usar SSL
echo "Aplicando configuraciÃ³n HTTPS..."

# Reemplazar variables en template
sed "s/\${DOMAIN}/$DOMAIN/g" nginx/web-ssl.conf.template > nginx/web-ssl.conf

# Reemplazar configuraciÃ³n activa
cat nginx/web-ssl.conf > nginx/web.conf

# 6. Recargar Nginx
echo "Recargando servidor web..."
$DOCKER_CMD exec web nginx -s reload

echo ""
echo "=================================================="
echo -e "${GREEN}ðŸŽ‰ Â¡HTTPS Habilitado!${NC}"
echo "=================================================="
echo "Accede ahora a: https://$DOMAIN"
echo ""
echo "Nota: El certificado se renovarÃ¡ automÃ¡ticamente."
