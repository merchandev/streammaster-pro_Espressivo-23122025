# 🚀 Guía de Despliegue - StreamMaster Pro v2.0

## ✅ Sistema Simplificado - Sin API

Esta versión elimina completamente el sistema de backend API/chat y proporciona una solución simple y funcional de streaming RTMP → HLS → Player.

---

## 📦 Estructura del Proyecto

```
streammaster-pro/
├── frontend/               # Frontend estático (Nginx)
│   ├── index.html         # Página principal con configuración
│   ├── player.html        # Player de video HLS
│   └── style.css          # Estilos
├── nginx/
│   ├── nginx.conf         # Configuración RTMP + HLS
│   └── Dockerfile         # Imagen personalizada nginx-rtmp
├── docker-compose.hostinger.yml
└── DESPLIEGUE.md          # Esta guía
```

---

## 🔧 Pasos de Despliegue en Hostinger VPS

### 1. Conectarse por SSH

```bash
ssh root@72.62.86.94
```

### 2. Ir al directorio del proyecto

```bash
cd /docker/streammaster-pro
```

### 3. Actualizar repositorio

```bash
git pull origin main
```

### 4. Detener servicios actuales

```bash
docker-compose -f docker-compose.hostinger.yml down
```

### 5. Limpiar volúmenes antiguos (opcional pero recomendado)

```bash
docker-compose -f docker-compose.hostinger.yml down -v
```

### 6. Reconstruir e iniciar servicios

```bash
docker-compose -f docker-compose.hostinger.yml up -d --build
```

### 7. Verificar estado de los servicios

```bash
docker-compose -f docker-compose.hostinger.yml ps
```

Deberías ver:
- `streammaster-rtmp` - **Up** (Puerto 1935 RTMP, 8080 HLS)
- `streammaster-web` - **Up** (Puerto 80)

### 8. Ver logs en tiempo real

```bash
docker-compose -f docker-compose.hostinger.yml logs -f
```

---

## 🧪 Verificación del Sistema

### A. Verificar que nginx web sirve los archivos correctamente

```bash
curl http://localhost
```

Deberías ver el HTML de `index.html`.

### B. Verificar servicio RTMP

```bash
curl http://localhost:8080/stat
```

Deberías ver las estadísticas XML de nginx-rtmp.

### C. Verificar desde el navegador

1. **Página principal**: `http://72.62.86.94`
2. **Player**: `http://72.62.86.94/player.html`
3. **Estadísticas RTMP**: `http://72.62.86.94:8080/stat`

---

## 📡 Configuración de OBS/vMix

### Para OBS Studio:

1. Abre **OBS Studio**
2. Ve a **Configuración → Emisión**
3. Configuración:
   - **Servicio**: Personalizado
   - **Servidor**: `rtmp://72.62.86.94:1935/live`
   - **Clave de transmisión**: `mistream`
4. En **Salida** (Avanzado):
   - **Encoder**: x264 o NVENC H264
   - **Bitrate**: 3000-5000 kbps
   - **Keyframe Interval**: 2 segundos
   - **Preset**: veryfast (x264) o Quality (NVENC)
5. Haz clic en **Iniciar transmisión**

### Para vMix:

1. Abre **vMix**
2. Ve a **Settings → Outputs → External**
3. Configuración:
   - **Server**: `rtmp://72.62.86.94:1935/live`
   - **Stream Key**: `mistream`
   - **Video Bitrate**: 3000-5000 kbps
   - **Keyframe**: 2 segundos
4. Haz clic en **Stream**

---

## 🎥 Ver el Stream

Una vez que OBS/vMix esté transmitiendo:

1. Abre en el navegador: `http://72.62.86.94/player.html`
2. El video debería comenzar automáticamente
3. La latencia será de **3-5 segundos**

---

## 🔍 Troubleshooting

### Problema: Error 403 Forbidden en puerto 80

**Causa**: Los archivos del frontend no se están sirviendo.

**Solución**:
```bash
cd /docker/streammaster-pro
ls -la frontend/  # Verificar que existan index.html, player.html, style.css
chmod -R 755 frontend/
docker-compose -f docker-compose.hostinger.yml restart web
```

### Problema: No se conecta RTMP desde OBS

**Causa**: Puerto 1935 bloqueado o servicio no corriendo.

**Solución**:
```bash
# Verificar firewall
sudo ufw status
sudo ufw allow 1935/tcp

# Verificar que el servicio esté corriendo
docker-compose -f docker-compose.hostinger.yml logs rtmp-server
```

### Problema: Player muestra "Stream no disponible"

**Causa**: No hay transmisión activa o HLS no está generándose.

**Solución**:
```bash
# 1. Verificar que OBS esté transmitiendo
# 2. Verificar logs del RTMP
docker-compose -f docker-compose.hostinger.yml logs rtmp-server

# 3. Verificar que se estén creando archivos HLS
docker exec streammaster-rtmp ls -la /tmp/streams/hls/

# Deberías ver archivos .m3u8 y .ts
```

### Problema: Stream se corta o hay buffering

**Causa**: Red lenta o configuración de OBS incorrecta.

**Solución**:
1. Reducir bitrate en OBS a 2000-3000 kbps
2. Verificar conexión de internet del encoder
3. Usar preset más rápido en OBS (ultrafast)

---

## 📊 Monitoreo

### Ver logs en tiempo real:

```bash
docker-compose -f docker-compose.hostinger.yml logs -f rtmp-server
docker-compose -f docker-compose.hostinger.yml logs -f web
```

### Ver estadísticas RTMP:

Navega a: `http://72.62.86.94:8080/stat`

---

## 🔐 Seguridad (Opcional)

Si quieres proteger el stream con contraseña, edita `nginx/nginx.conf`:

```nginx
application live {
    live on;
    
    # Agregar validación de stream key
    on_publish http://localhost/auth;
    
    # ... resto de configuración
}
```

---

## 🆘 Comandos Útiles

```bash
# Ver todos los contenedores
docker-compose -f docker-compose.hostinger.yml ps

# Reiniciar un servicio específico
docker-compose -f docker-compose.hostinger.yml restart web
docker-compose -f docker-compose.hostinger.yml restart rtmp-server

# Ver uso de recursos
docker stats

# Acceder a un contenedor
docker exec -it streammaster-web sh
docker exec -it streammaster-rtmp sh

# Limpiar todo y empezar de cero
docker-compose -f docker-compose.hostinger.yml down -v
docker-compose -f docker-compose.hostinger.yml up -d --build
```

---

## ✅ Checklist de Verificación

- [ ] Servicios `streammaster-rtmp` y `streammaster-web` en estado **Up**
- [ ] Puerto 80 accesible desde navegador
- [ ] Puerto 1935 abierto en firewall
- [ ] Archivos en `frontend/` tienen permisos 755
- [ ] OBS puede conectarse al servidor RTMP
- [ ] Player muestra video cuando OBS transmite
- [ ] Latencia es de 3-5 segundos

---

## 📝 Notas Importantes

1. **Sin sistema de tokens**: Esta versión usa una clave fija `mistream`
2. **Sin backend API**: Todo es estático, solo nginx
3. **Puertos necesarios**:
   - 80: Web frontend
   - 1935: RTMP input
   - 8080: HLS output
4. **Latencia optimizada**: 3-5 segundos gracias a fragmentos HLS de 2s

---

## 🎯 Siguiente Paso

Para desplegar ahora:

```bash
ssh root@72.62.86.94
cd /docker/streammaster-pro
git pull
docker-compose -f docker-compose.hostinger.yml down
docker-compose -f docker-compose.hostinger.yml up -d --build
docker-compose -f docker-compose.hostinger.yml ps
```

¡Listo! Tu sistema de streaming debería estar funcionando.
