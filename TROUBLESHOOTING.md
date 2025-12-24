# 🔧 Guía de Troubleshooting - Servicios en Restarting

## 🚨 Problema Detectado

**Estado actual:**
- ❌ streammaster-api: Restarting
- ❌ streammaster-rtmp: Restarting  
- ✅ streammaster-redis: Running
- ✅ streammaster-web: Running (pero muestra 403 Forbidden)

---

## 📋 Pasos para Diagnosticar y Solucionar

### 1. Conectarse por SSH al VPS

```bash
ssh root@72.62.86.94
```

### 2. Ver Logs de los Contenedores que Fallan

#### Ver logs del API (que está fallando):
```bash
cd /docker/streammaster-pro
docker-compose logs streammaster-api --tail=50
```

#### Ver logs del RTMP (que está fallando):
```bash
docker-compose logs streammaster-rtmp --tail=50
```

#### Ver todos los logs:
```bash
docker-compose logs --tail=100
```

---

## 🔧 Soluciones Comunes

### Problema 1: API No Arranca (Python/Flask)

**Posibles causas:**
- Falta archivo `.env` con SECRET_KEY
- Error en el código Python
- Problema con Redis

**Solución:**

```bash
cd /docker/streammaster-pro

# Crear archivo .env si no existe
cat > .env << 'EOF'
SECRET_KEY=tu-clave-secreta-super-segura-cambiar-esto
MAX_CONNECTIONS=1000
REDIS_HOST=redis
REDIS_PORT=6379
DOMAIN=72.62.86.94
EOF

# Reiniciar solo el API
docker-compose restart api

# Ver logs en tiempo real
docker-compose logs -f api
```

---

### Problema 2: RTMP No Arranca (Nginx)

**Posibles causas:**
- Error en nginx.conf
- Puerto 1935 ocupado
- Falta FFmpeg en el contenedor

**Solución:**

```bash
# Verificar si el puerto está ocupado
sudo netstat -tulpn | grep 1935

# Ver logs específicos del RTMP
docker-compose logs rtmp-server --tail=100

# Reconstruir la imagen
cd /docker/streammaster-pro
docker-compose up -d --build rtmp-server

# Ver logs en tiempo real
docker-compose logs -f rtmp-server
```

---

### Problema 3: 403 Forbidden en Web (SOLUCIONADO)

**Síntomas:**
- Nginx muestra "403 Forbidden" 
- Error: "directory index of '/usr/share/nginx/html/' is forbidden"
- No se muestra el panel de control

**Causas:**
1. Archivos del frontend no se montaron correctamente en el contenedor
2. Falta configuración personalizada de nginx (web.conf)
3. Nginx usa la configuración por defecto que no tiene index.html

**Solución Automática (Recomendada):**

Ejecuta el script de reparación automática:

```bash
cd /docker/streammaster-pro

# Descarga o usa el script incluido
chmod +x fix-web.sh
./fix-web.sh
```

O usa el script de despliegue completo:

```bash
chmod +x deploy-fix.sh
./deploy-fix.sh
```

**Solución Manual:**

```bash
cd /docker/streammaster-pro

# 1. Verificar que existan los archivos del frontend
ls -la frontend/
# Deberías ver: index.html, player.html, style.css

# 2. Verificar que el archivo web.conf existe
ls -la nginx/web.conf

# 3. Detener el contenedor web
docker stop streammaster-web
docker rm streammaster-web

# 4. Verificar docker-compose.yml incluye la configuración
# Debe tener estas 2 líneas en volumes del servicio web:
#   - ./frontend:/usr/share/nginx/html:ro
#   - ./nginx/web.conf:/etc/nginx/conf.d/default.conf:ro

# 5. Reiniciar el servicio
docker-compose up -d web

# 6. Verificar archivos dentro del contenedor
docker exec streammaster-web ls -lah /usr/share/nginx/html/

# 7. Verificar configuración nginx
docker exec streammaster-web cat /etc/nginx/conf.d/default.conf

# 8. Verificar que nginx responde
docker exec streammaster-web wget -O- http://localhost

# 9. Probar desde el host
curl -I http://localhost
```

**Verificar que funciona:**

```bash
# Desde el servidor
curl http://localhost

# Desde tu navegador
http://72.62.86.94
```

Si aún ves 403:
- Verifica permisos: `chmod -R 755 frontend/`
- Reconstruir todo: `docker-compose down && docker-compose up -d --build`
- Ver logs: `docker logs streammaster-web --tail 50`

- Ver logs: `docker logs streammaster-web --tail 50`

---

### Problema 4: Error 404 en el Stream (SOLUCIONADO)

**Síntomas:**
- El player muestra "Señal Perdida" o pantalla negra.
- Los logs del RTMP muestran: `open() "/tmp/streams/hls/mistream.m3u8" failed (2: No such file or directory)`.

**Causa:**
- Nginx estaba configurado con `hls_nested on` (creando `/mistream/index.m3u8`) pero el player buscaba `/mistream.m3u8`.
- **Desincronización de Despliegue:** Se actualizó el código (`git pull`) pero NO se reconstruyó el contenedor, por lo que Nginx seguía usando la configuración vieja.

**Solución:**
Es necesario reconstruir el contenedor para que aplique el cambio de `nginx.conf`.

```bash
cd /docker/streammaster-pro
git pull origin main

# Detener contenedores
docker-compose down

# 🔥 CRÍTICO: Reconstruir imagen para actualizar nginx.conf
docker-compose up -d --build rtmp-server

# Verificar logs
docker-compose logs -f rtmp-server
```

---

## 🚀 Script de Solución Rápida

Ejecuta este script completo en tu VPS:

```bash
#!/bin/bash
cd /docker/streammaster-pro

echo "🔧 Solucionando problemas..."

# 1. Crear .env si no existe
if [ ! -f .env ]; then
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
    echo "MAX_CONNECTIONS=1000" >> .env
    echo "REDIS_HOST=redis" >> .env
    echo "REDIS_PORT=6379" >> .env
    echo "✅ Archivo .env creado"
fi

# 2. Verificar archivos del frontend
if [ ! -f "frontend/index.html" ]; then
    echo "❌ ERROR: Archivos del frontend no encontrados"
    echo "Ejecuta: git pull origin main"
    exit 1
fi

# 3. Arreglar permisos
chmod -R 755 frontend/
chmod -R 755 backend/
chmod -R 755 nginx/

# 4. Detener todo
docker-compose down

# 5. Limpiar volúmenes antiguos (opcional, pero ayuda)
# docker-compose down -v

# 6. Reconstruir e iniciar
docker-compose up -d --build

# 7. Esperar 10 segundos
echo "⏳ Esperando que los servicios inicien..."
sleep 10

# 8. Verificar estado
docker-compose ps

# 9. Ver logs de servicios problemáticos
echo ""
echo "📊 Logs del API:"
docker-compose logs api --tail=20

echo ""
echo "📊 Logs del RTMP:"
docker-compose logs rtmp-server --tail=20

echo ""
echo "✅ Proceso completado. Revisa los logs arriba para detectar errores."
```

**Para ejecutarlo:**
```bash
# Copiar el script arriba a un archivo
nano fix-services.sh

# Pegar el contenido del script

# Dar permisos de ejecución
chmod +x fix-services.sh

# Ejecutar
./fix-services.sh
```

---

## 🔍 Comandos Útiles de Diagnóstico

```bash
# Ver estado de todos los contenedores
docker-compose ps

# Ver uso de recursos
docker stats

# Ver logs en tiempo real de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f streammaster-api

# Entrar a un contenedor para debugging
docker exec -it streammaster-api /bin/bash

# Reiniciar un servicio específico
docker-compose restart streammaster-api

# Reconstruir todo desde cero
docker-compose down
docker-compose up -d --build

# Ver red de Docker
docker network ls
docker network inspect streammaster-pro_streamnet
```

---

## 📝 Checklist de Verificación

- [ ] Archivo `.env` existe con SECRET_KEY
- [ ] Directorio `frontend/` tiene archivos (index.html, etc.)
- [ ] Directorio `backend/` tiene archivos (app.py, etc.)
- [ ] Directorio `nginx/` tiene archivos (nginx.conf, Dockerfile)
- [ ] Permisos correctos (755) en todos los directorios
- [ ] Puerto 1935 no está ocupado
- [ ] Puerto 80 no está ocupado
- [ ] Redis está corriendo correctamente

---

## 🆘 Si Nada Funciona

**Opción 1: Reinstalar completamente**

```bash
cd /docker/streammaster-pro
docker-compose down -v  # Elimina todo incluidos volúmenes
git pull origin main     # Actualiza el código
docker-compose up -d --build  # Reconstruye todo
```

**Opción 2: Verificar que el repositorio está completo**

```bash
cd /docker/streammaster-pro
git status
git pull origin main
ls -la  # Deberías ver todos los directorios
```

---

## 📊 Logs Específicos que Buscar

### En los logs del API busca:

- `ModuleNotFoundError` - Falta instalar dependencias
- `Connection refused` - No puede conectar con Redis
- `SECRET_KEY` - Falta variable de entorno
- `Traceback` - Error en Python

### En los logs del RTMP busca:

- `nginx: [emerg]` - Error de configuración
- `bind() to 0.0.0.0:1935 failed` - Puerto ocupado
- `open() "/etc/nginx/nginx.conf" failed` - Archivo no encontrado

---

## 💡 Siguiente Paso

**Ejecuta esto ahora en tu VPS:**

```bash
ssh root@72.62.86.94
cd /docker/streammaster-pro
docker-compose logs streammaster-api --tail=50
docker-compose logs streammaster-rtmp --tail=50
```

Copia los logs y compártelos para ver exactamente qué está fallando.
