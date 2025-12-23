#!/bin/bash
# StreamMaster Pro - Fix 403 Error
# Ejecutar en: /docker/streammaster-pro

echo "🔧 Reparando StreamMaster Web..."
cd /docker/streammaster-pro

# Detener contenedor
docker stop streammaster-web 2>/dev/null && docker rm streammaster-web 2>/dev/null

# Actualizar nginx/web.conf
cat > nginx/web.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    autoindex on;
    location / {
        try_files $uri $uri/ /index.html;
    }
    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS' always;
    add_header Access-Control-Allow-Headers '*' always;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log debug;
}
EOF

# Actualizar docker-compose.yml si es necesario
grep -q "nginx/web.conf:/etc/nginx/conf.d/default.conf" docker-compose.yml || \
sed -i '/- \.\/frontend:\/usr\/share\/nginx\/html:ro/a\      - ./nginx/web.conf:/etc/nginx/conf.d/default.conf:ro' docker-compose.yml

# Ajustar permisos
chmod -R 755 frontend/ && chmod 644 nginx/web.conf

# Reiniciar servicio
docker-compose up -d web && sleep 3

# Verificaciones
echo ""
echo "📋 Estado del contenedor:"
docker ps | grep streammaster-web

echo ""
echo "📂 Archivos en el contenedor:"
docker exec streammaster-web ls -lah /usr/share/nginx/html/

echo ""
echo "🌐 Test HTTP:"
curl -I http://localhost

echo ""
echo "✅ Completado! Verifica: http://72.62.86.94"
