# 🚀 Instalación Completa en Hostinger - StreamMaster Pro

## ✅ Nueva Configuración Mejorada

Esta versión incluye:
- ✅ Todas las configuraciones embebidas en las imágenes Docker
- ✅ Health checks automáticos para todos los servicios
- ✅ Dependencias condicionales (los servicios esperan que otros estén sanos)
- ✅ Reinicio automático en caso de fallos
- ✅ Variables de entorno con valores por defecto seguros

---

## 📋 Instalación en Hostinger

### Paso 1: Conectarse por SSH
```bash
ssh root@72.62.86.94
```

### Paso 2: Ir al Directorio del Proyecto
```bash
cd /docker/streammaster-pro
```

### Paso 3: Actualizar Código desde GitHub
```bash
git pull origin main
```

### Paso 4: Crear Archivo .env (Recomendado)
```bash
cat > .env << 'EOF'
SECRET_KEY=$(openssl rand -hex 32)
MAX_CONNECTIONS=1000
EOF
```

O con una clave específica:
```bash
cat > .env << 'EOF'
SECRET_KEY=tu-clave-secreta-super-segura-cambiar-esto
MAX_CONNECTIONS=1000
EOF
```

### Paso 5: Limpiar Instalación Anterior
```bash
docker compose down -v
docker system prune -af --volumes
```

### Paso 6: Construir e Iniciar (NUEVO)
```bash
docker compose up -d --build
```

### Paso 7: Verificar Estado
```bash
docker compose ps
```

**Todos los servicios deberían mostrar "healthy" después de 30-60 segundos.**

### Paso 8: Ver Logs (Si hay problemas)
```bash
docker compose logs -f
```

---

## 🎯 Comando TODO-EN-UNO (Instalación Completa)

**Copia y pega esto para instalar desde cero:**

```bash
cd /docker/streammaster-pro && \
git pull origin main && \
cat > .env << 'EOF'
SECRET_KEY=cambiar-esta-clave-secreta-por-una-segura
MAX_CONNECTIONS=1000
EOF
docker compose down -v && \
docker system prune -af --volumes && \
docker compose up -d --build && \
echo "⏳ Esperando que los servicios inicien (60 segundos)..." && \
sleep 60 && \
echo "" && \
echo "📊 Estado de servicios:" && \
docker compose ps && \
echo "" && \
echo "✅ Instalación completada"
```

---

## 🔍 Verificar que Todo Funciona

### 1. Ver Estado de Health Checks:
```bash
docker compose ps
```

Deberías ver algo como:
```
NAME                  STATUS
streammaster-api      Up (healthy)
streammaster-redis    Up (healthy)
streammaster-rtmp     Up (healthy)
streammaster-web      Up (healthy)
```

### 2. Probar API:
```bash
curl http://localhost:5000/api/health
```

Debería responder:
```json
{"status":"healthy","services":["redis","rtmp"]}
```

### 3. Probar Frontend:
```bash
curl http://localhost/
```

Debería mostrar el HTML del panel de control.

### 4. Probar HLS:
```bash
curl http://localhost:8080/stat
```

Debería mostrar estadísticas del servidor RTMP.

---

## 🆘 Solución de Problemas

### Si un servicio no está "healthy":

**Ver logs específicos:**
```bash
# API
docker compose logs api --tail=100

# RTMP
docker compose logs rtmp-server --tail=100

# Redis
docker compose logs redis --tail=50

# Web
docker compose logs web --tail=50
```

### Reiniciar un servicio específico:
```bash
docker compose restart <nombre-servicio>
```

### Reconstruir un servicio específico:
```bash
docker compose up -d --build <nombre-servicio>
```

### Limpiar todo y empezar de cero:
```bash
cd /docker/streammaster-pro
docker compose down -v
docker system prune -af --volumes
docker compose up -d --build
```

---

## 📊 Monitoreo en Tiempo Real

### Ver logs de todos los servicios:
```bash
docker compose logs -f
```

### Ver logs de un servicio específico:
```bash
docker compose logs -f api
docker compose logs -f rtmp-server
```

### Ver uso de recursos:
```bash
docker stats
```

---

## ✅ Prueba Final

Una vez que todos los servicios estén "healthy":

1. **Abre en tu navegador:**
   ```
   http://72.62.86.94
   ```

2. **Genera un token de prueba**

3. **Configura OBS:**
   ```
   Servidor: rtmp://72.62.86.94:1935/live
   Clave: [tu-token-generado]
   ```

4. **Inicia streaming**

5. **Verifica que aparezca en:**
   ```
   http://72.62.86.94:8080/stat
   ```

---

## 🎉 ¡Listo!

Tu servidor de streaming debería estar funcionando completamente.

**URLs importantes:**
- Panel: `http://72.62.86.94`
- API: `http://72.62.86.94/api/health`
- Stats RTMP: `http://72.62.86.94:8080/stat`
- HLS Streams: `http://72.62.86.94:8080/hls/[TOKEN]_720p.m3u8`
