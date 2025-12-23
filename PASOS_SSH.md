# 🔧 Guía Paso a Paso - Reparar StreamMaster por SSH

## 📋 Pre-requisitos
- ✅ Conexión SSH configurada
- ✅ Acceso al servidor: `root@72.62.86.94`
- ✅ Proyecto ubicado en: `/docker/streammaster-pro`

---

## 🚀 PASO 1: Conectarse al Servidor

Abre tu terminal (PowerShell, CMD o Windows Terminal) y ejecuta:

```bash
ssh root@72.62.86.94
```

**Nota:** Te pedirá la contraseña del servidor.

---

## 🔍 PASO 2: Verificar que estás en el directorio correcto

Una vez conectado, ejecuta:

```bash
cd /docker/streammaster-pro
pwd
ls -la
```

Deberías ver los directorios: `frontend/`, `nginx/`, `backend/`, etc.

---

## 🛠️ PASO 3: Ejecutar el Script de Reparación Completo

**Opción A: Copiar y pegar todo el script de una vez (RECOMENDADO)**

Copia TODO el siguiente bloque y pégalo en la terminal SSH:

```bash
#!/bin/bash
echo "==============================================="
echo "🔧 Reparando StreamMaster Web - Error 403"
echo "==============================================="
echo ""

# Ir al directorio del proyecto
cd /docker/streammaster-pro

# PASO 1: Detener el contenedor web
echo "🛑 Deteniendo contenedor web..."
docker stop streammaster-web 2>/dev/null
docker rm streammaster-web 2>/dev/null
echo "✅ Contenedor detenido"
echo ""

# PASO 2: Crear/actualizar nginx/web.conf
echo "📝 Actualizando nginx/web.conf..."
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

echo "✅ nginx/web.conf actualizado"
echo ""

# PASO 3: Verificar que web.conf se creó correctamente
echo "🔍 Verificando nginx/web.conf..."
if [ -f nginx/web.conf ]; then
    echo "✅ Archivo existe"
    echo "Contenido:"
    cat nginx/web.conf
else
    echo "❌ ERROR: No se pudo crear nginx/web.conf"
    exit 1
fi
echo ""

# PASO 4: Verificar archivos del frontend
echo "📂 Verificando archivos del frontend..."
if [ ! -f frontend/index.html ]; then
    echo "❌ ERROR: No existe frontend/index.html"
    exit 1
fi
echo "✅ Archivos del frontend OK"
echo ""

# PASO 5: Verificar/actualizar docker-compose.yml
echo "🔍 Verificando docker-compose.yml..."
if grep -q "nginx/web.conf:/etc/nginx/conf.d/default.conf" docker-compose.yml; then
    echo "✅ docker-compose.yml ya tiene web.conf montado"
else
    echo "📝 Actualizando docker-compose.yml..."
    # Hacer backup
    cp docker-compose.yml docker-compose.yml.backup
    
    # Agregar la línea de web.conf después de la línea del frontend
    sed -i '/- \.\/frontend:\/usr\/share\/nginx\/html:ro/a\      - ./nginx/web.conf:/etc/nginx/conf.d/default.conf:ro' docker-compose.yml
    
    echo "✅ docker-compose.yml actualizado"
fi
echo ""

# PASO 6: Verificar permisos
echo "🔐 Verificando permisos..."
chmod -R 755 frontend/
chmod 644 nginx/web.conf
echo "✅ Permisos ajustados"
echo ""

# PASO 7: Reiniciar el servicio web
echo "🚀 Iniciando servicio web..."
docker-compose up -d web
echo ""

# PASO 8: Esperar que el servicio esté listo
echo "⏳ Esperando 3 segundos..."
sleep 3
echo ""

# PASO 9: Verificar que el contenedor está corriendo
echo "🔍 Verificando estado del contenedor..."
if docker ps | grep -q streammaster-web; then
    echo "✅ streammaster-web está corriendo"
else
    echo "❌ ERROR: streammaster-web no está corriendo"
    echo "Logs:"
    docker logs streammaster-web --tail 30
    exit 1
fi
echo ""

# PASO 10: Verificar archivos dentro del contenedor
echo "📂 Verificando archivos dentro del contenedor..."
echo "Contenido de /usr/share/nginx/html/:"
docker exec streammaster-web ls -lah /usr/share/nginx/html/
echo ""

# PASO 11: Verificar configuración nginx en el contenedor
echo "⚙️ Verificando configuración nginx..."
echo "Contenido de /etc/nginx/conf.d/default.conf:"
docker exec streammaster-web cat /etc/nginx/conf.d/default.conf
echo ""

# PASO 12: Test nginx
echo "🧪 Verificando que nginx responde..."
if docker exec streammaster-web wget -O /dev/null -q http://localhost; then
    echo "✅ Nginx responde correctamente"
else
    echo "❌ ERROR: Nginx no responde"
    docker logs streammaster-web --tail 30
    exit 1
fi
echo ""

# PASO 13: Ver logs recientes
echo "📋 Logs recientes:"
docker logs streammaster-web --tail 15
echo ""

# PASO 14: Test desde el host
echo "🌐 Probando desde el host..."
curl -I http://localhost
echo ""

# PASO 15: Mostrar información de puertos
echo "🔌 Puertos expuestos:"
docker port streammaster-web
echo ""

echo "==============================================="
echo "✅ REPARACIÓN COMPLETADA"
echo "==============================================="
echo ""
echo "🔍 Verifica en tu navegador:"
echo "   http://72.62.86.94"
echo ""
echo "Si ves el panel de StreamMaster Pro, ¡todo está funcionando!"
echo ""
```

---

## ✅ PASO 4: Verificar que Funciona

Después de ejecutar el script, deberías ver:

```
✅ REPARACIÓN COMPLETADA
```

Luego, **abre tu navegador** y visita:
- http://72.62.86.94

Deberías ver el **panel de StreamMaster Pro** con el logo, features y botones.

---

## 🔍 PASO 5: Verificación Adicional

Si quieres ver más detalles, ejecuta en el servidor:

```bash
# Ver estado de contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f web

# Probar acceso HTTP
curl http://localhost

# Ver configuración nginx
docker exec streammaster-web cat /etc/nginx/conf.d/default.conf
```

---

## 🆘 Si Algo Sale Mal

### Ver logs detallados:
```bash
docker logs streammaster-web --tail 50
```

### Verificar archivos:
```bash
ls -la frontend/
docker exec streammaster-web ls -la /usr/share/nginx/html/
```

### Reiniciar todo:
```bash
docker-compose down
docker-compose up -d
```

### Verificar firewall:
```bash
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw reload
```

---

## 📝 Notas Importantes

- El script hace **backup automático** de `docker-compose.yml`
- Puedes ejecutar el script **múltiples veces** sin problemas
- Los cambios son **seguros** y no afectan otros servicios
- Si algo falla, el script te mostrará los logs automáticamente

---

## ✨ Resultado Esperado

Después de la reparación:
- ✅ Panel web accesible en http://72.62.86.94
- ✅ Player accesible en http://72.62.86.94/player.html
- ✅ Sin errores 403
- ✅ Nginx sirviendo archivos correctamente

---

**¡Estoy listo para ayudarte cuando estés conectado al servidor!**
