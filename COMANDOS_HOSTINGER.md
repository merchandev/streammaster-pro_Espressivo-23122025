# 🚀 Comandos Correctos para Hostinger Ubuntu

## ⚠️ IMPORTANTE
Hostinger usa **`docker compose`** (con ESPACIO) no `docker-compose` (con guión).

---

## 📊 Ver Estado y Logs

### 1. Ver estado de contenedores:
```bash
cd /docker/streammaster-pro && docker compose ps
```

### 2. Ver logs del API:
```bash
cd /docker/streammaster-pro && docker compose logs streammaster-api --tail=100
```

### 3. Ver logs del RTMP:
```bash
cd /docker/streammaster-pro && docker compose logs streammaster-rtmp --tail=100
```

### 4. Ver todos los logs:
```bash
cd /docker/streammaster-pro && docker compose logs --tail=50
```

### 5. Ver logs en tiempo real:
```bash
cd /docker/streammaster-pro && docker compose logs -f
```

---

## 🔧 Reparar Servicios

### Crear archivo .env (PASO OBLIGATORIO):
```bash
cd /docker/streammaster-pro && cat > .env << 'EOF'
SECRET_KEY=cambiar-por-clave-secreta-super-segura-12345
MAX_CONNECTIONS=1000
REDIS_HOST=redis
REDIS_PORT=6379
DOMAIN=72.62.86.94
EOF
```

### Reiniciar servicios:
```bash
cd /docker/streammaster-pro && docker compose restart
```

### Reconstruir servicios problemáticos:
```bash
cd /docker/streammaster-pro && docker compose up -d --build streammaster-api streammaster-rtmp
```

---

## 🚀 Script Completo de Reparación

**Copia y pega esto TODO JUNTO:**

```bash
cd /docker/streammaster-pro && \
cat > .env << 'EOF'
SECRET_KEY=tu-clave-secreta-super-segura-cambiar-esto-ahora
MAX_CONNECTIONS=1000
REDIS_HOST=redis
REDIS_PORT=6379
DOMAIN=72.62.86.94
EOF
echo "✅ Archivo .env creado" && \
chmod -R 755 frontend/ backend/ nginx/ && \
echo "✅ Permisos arreglados" && \
docker compose down && \
echo "🔄 Reconstruyendo servicios..." && \
docker compose up -d --build && \
sleep 10 && \
echo "" && \
echo "📊 Estado de servicios:" && \
docker compose ps && \
echo "" && \
echo "✅ Proceso completado"
```

---

## 🔍 Diagnóstico Completo

```bash
cd /docker/streammaster-pro && \
echo "=== ESTADO ===" && \
docker compose ps && \
echo "" && \
echo "=== LOGS API ===" && \
docker compose logs streammaster-api --tail=20 && \
echo "" && \
echo "=== LOGS RTMP ===" && \
docker compose logs streammaster-rtmp --tail=20
```

---

## 🆘 Si Sigue Fallando

### Limpiar y empezar de cero:
```bash
cd /docker/streammaster-pro && \
docker compose down -v && \
git pull origin main && \
docker compose up -d --build
```

---

## 📋 Orden Recomendado de Ejecución

1. **Ejecuta el script completo de reparación** (arriba)
2. **Espera 10 segundos**
3. **Ejecuta el diagnóstico completo** para ver el resultado
4. **Si aún falla**, comparte los logs

---

## ✅ Comando Inmediato (Ejecuta AHORA)

**Empieza por aquí:**

```bash
cd /docker/streammaster-pro && cat > .env << 'EOF'
SECRET_KEY=clave-secreta-super-segura-12345
MAX_CONNECTIONS=1000
REDIS_HOST=redis
REDIS_PORT=6379
DOMAIN=72.62.86.94
EOF
docker compose restart
```

**Luego verifica el estado:**

```bash
cd /docker/streammaster-pro && docker compose ps
```
