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

# 1. Solicitar Dominio y Email
read -p "Ingresa tu dominio (ej: tv.monagasvision.com): " DOMAIN
read -p "Ingresa tu email (para registro de Let's Encrypt): " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: Dominio y Email son requeridos.${NC}"
    exit 1
fi

echo ""
echo -e "Configurando SSL para: ${GREEN}$DOMAIN${NC}"
echo "Esto tomará unos minutos..."
echo ""

# 2. Asegurar que los directorios existen
mkdir -p ./data/certbot/conf
mkdir -p ./data/certbot/www

# 3. Descargar script recomendado de Certbot (init-letsencrypt) o usar método directo
# Método Directo Simplificado:

# Paso A: Iniciar Nginx con configuración HTTP básica (ya debe estar corriendo)
echo "reiniciando servidor web para validación..."
docker-compose up -d web

echo "Esperando a que Nginx inicie..."
sleep 5

# Paso B: Solicitar Certificado
echo "Solicitando certificado a Let's Encrypt..."
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    --email $EMAIL \
    --d $DOMAIN \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal" certbot

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al obtener el certificado. Verifica que tu dominio apunte a este servidor.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Certificado obtenido correctamente.${NC}"

# 4. Configurar Nginx para usar SSL
echo "Aplicando configuración HTTPS..."

# Reemplazar variables en template
sed "s/\${DOMAIN}/$DOMAIN/g" nginx/web-ssl.conf.template > nginx/web-ssl.conf

# Reemplazar configuración activa (web.conf) con la versión SSL (web-ssl.conf)
# Hacemos esto copiando el contenido, para que el volumen montado lo vea
cat nginx/web-ssl.conf > nginx/web.conf

# 5. Recargar Nginx
echo "Recargando servidor web..."
docker-compose exec web nginx -s reload

echo ""
echo "=================================================="
echo -e "${GREEN}🎉 ¡HTTPS Habilitado!${NC}"
echo "=================================================="
echo "Accede ahora a: https://$DOMAIN"
echo ""
echo "Nota: El certificado se renovará automáticamente."
