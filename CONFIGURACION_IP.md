# 🎬 StreamMaster Pro - Configuración con IP: 72.62.86.94

## 🌐 URLs de Acceso

### Panel de Control
```
http://72.62.86.94
```

### API Health Check
```
http://72.62.86.94/api/health
```

### Estadísticas del Servidor
```
http://72.62.86.94:8080/stat
```

---

## 📹 Configuración para OBS Studio

### Ajustes → Emisión

```
Servicio: Personalizado
Servidor: rtmp://72.62.86.94:1935/live
Clave de emisión: [TOKEN QUE GENERES EN EL PANEL]
```

### Configuración Recomendada

**Para 720p @ 30fps (Recomendado):**
```
Encoder: Hardware (NVENC)
Bitrate: 3000 kbps
Keyframe Interval: 2 segundos
Rate Control: CBR
Preset: Quality
Profile: high
```

**Para 1080p @ 30fps:**
```
Encoder: Hardware (NVENC)
Bitrate: 4500 kbps
Keyframe Interval: 2 segundos
Rate Control: CBR
Preset: Quality
Profile: high
```

### Ejemplo Completo OBS

```
┌─────────────────────────────────────────┐
│ Ajustes → Emisión                       │
├─────────────────────────────────────────┤
│ Servicio: Personalizado                 │
│ Servidor: rtmp://72.62.86.94:1935/live  │
│ Clave: abc123xyz456... (token generado) │
│                                          │
│ Ajustes → Salida                        │
│ Modo: Avanzado                          │
│ Encoder: NVIDIA NVENC H.264             │
│ Control de frecuencia: CBR              │
│ Bitrate: 3000 Kbps                      │
│ Keyframe: 2                             │
│ Preset: Quality                         │
│ Profile: high                           │
└─────────────────────────────────────────┘
```

---

## 🎚️ Configuración para vMix

### Settings → Streaming

```
Stream Type: RTMP
Server: rtmp://72.62.86.94:1935/live
Stream Key: [TOKEN QUE GENERES EN EL PANEL]
```

### Configuración Recomendada

**Para 720p @ 30fps:**
```
Video Bitrate: 3000 kbps
Audio Bitrate: 128 kbps
Framerate: 30
Encoder: Hardware (NVIDIA/AMD/Intel)
Quality: High
Profile: High
Keyframe: 2 seconds
```

**Para 1080p @ 30fps:**
```
Video Bitrate: 4500 kbps
Audio Bitrate: 128 kbps
Framerate: 30
Encoder: Hardware
Quality: High
Profile: High
Keyframe: 2 seconds
```

---

## ⚙️ Configuración para FFmpeg

### Comando básico (720p @ 30fps)

```bash
ffmpeg -re -i INPUT.mp4 \
  -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k \
  -vf "scale=1280:720" -g 60 -r 30 \
  -c:a aac -b:a 128k \
  -f flv "rtmp://72.62.86.94:1935/live/TU-TOKEN"
```

### Comando para 1080p @ 30fps

```bash
ffmpeg -re -i INPUT.mp4 \
  -c:v libx264 -preset veryfast -b:v 4500k -maxrate 4500k -bufsize 9000k \
  -vf "scale=1920:1080" -g 60 -r 30 \
  -c:a aac -b:a 128k \
  -f flv "rtmp://72.62.86.94:1935/live/TU-TOKEN"
```

### Stream desde webcam (Windows)

```bash
ffmpeg -f dshow -i video="Integrated Camera":audio="Microphone" \
  -c:v libx264 -preset veryfast -b:v 3000k \
  -c:a aac -b:a 128k \
  -f flv "rtmp://72.62.86.94:1935/live/TU-TOKEN"
```

---

## 👁️ URLs para Visualización (HLS)

Una vez que estés transmitiendo, los espectadores pueden ver en:

### Calidad Automática (adaptativa)
```
http://72.62.86.94:8080/hls/[TOKEN].m3u8
```

### Calidades Específicas

**1080p:**
```
http://72.62.86.94:8080/hls/[TOKEN]_1080p.m3u8
```

**720p:**
```
http://72.62.86.94:8080/hls/[TOKEN]_720p.m3u8
```

**480p:**
```
http://72.62.86.94:8080/hls/[TOKEN]_480p.m3u8
```

---

## 🔗 Código HTML para Incrustar

### Opción 1: Player Básico con HLS.js

```html
<!-- Reemplaza TU-TOKEN con el token generado -->
<div id="stream-player" style="max-width: 100%; aspect-ratio: 16/9;"></div>
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
<script>
    const video = document.createElement('video');
    video.controls = true;
    video.style.width = '100%';
    video.style.height = '100%';
    document.getElementById('stream-player').appendChild(video);
    
    if (Hls.isSupported()) {
        const hls = new Hls();
        hls.loadSource('http://72.62.86.94:8080/hls/TU-TOKEN_720p.m3u8');
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED, () => video.play());
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
        video.src = 'http://72.62.86.94:8080/hls/TU-TOKEN_720p.m3u8';
        video.addEventListener('loadedmetadata', () => video.play());
    }
</script>
```

### Opción 2: Iframe del Player Completo

```html
<iframe 
    src="http://72.62.86.94/player.html?stream=TU-TOKEN"
    width="100%" 
    height="500" 
    frameborder="0" 
    allowfullscreen>
</iframe>
```

---

## 🔑 Cómo Generar un Token

1. **Abre el panel de control:**
   ```
   http://72.62.86.94
   ```

2. **Selecciona tu encoder:**
   - OBS Studio
   - vMix
   - FFmpeg u otro

3. **Configura tu stream:**
   - Nombre: `mi_evento_2024`
   - Calidad: 720p @ 30fps
   - Expiración: 24 horas

4. **Click en "Generar Token"**

5. **Copia la configuración generada**
   - Se mostrará el servidor RTMP completo
   - Y la clave de stream única

---

## 🧪 Probar que el Servidor Funciona

### Desde tu navegador:

```
http://72.62.86.94/api/health
```

Deberías ver algo como:
```json
{
  "status": "healthy",
  "active_streams": 0,
  "total_viewers": 0,
  "available_slots": 1000,
  "encoders_supported": ["OBS", "VMIX", "FFMPEG"]
}
```

### Desde terminal (SSH):

```bash
# Ver servicios activos
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Probar conexión RTMP
curl http://localhost:8080/stat
```

---

## 🎯 Ejemplo Completo de Uso

### 1. Generar Token
- Ve a `http://72.62.86.94`
- Genera token, por ejemplo: `xK9mP2nQ8vL5tR3wY7z`

### 2. Configurar OBS
```
Servidor: rtmp://72.62.86.94:1935/live
Clave: xK9mP2nQ8vL5tR3wY7z
```

### 3. Iniciar Transmisión
- Click en "Iniciar transmisión" en OBS

### 4. Compartir con Espectadores
```html
<video id="player" controls style="width:100%"></video>
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
<script>
    const video = document.getElementById('player');
    const hls = new Hls();
    hls.loadSource('http://72.62.86.94:8080/hls/xK9mP2nQ8vL5tR3wY7z_720p.m3u8');
    hls.attachMedia(video);
    hls.on(Hls.Events.MANIFEST_PARSED, () => video.play());
</script>
```

---

## 📊 Monitoreo

### Estadísticas en Tiempo Real
```
http://72.62.86.94:8080/stat
```

### Panel de Control
```
http://72.62.86.94
```

### API Endpoints
```
GET http://72.62.86.94/api/health
GET http://72.62.86.94/api/streams/active
GET http://72.62.86.94/api/stream/[TOKEN]
```

---

## 🔒 Seguridad

**IMPORTANTE:** Esta IP es pública. Recomendaciones:

1. ✅ Configura un dominio con SSL (HTTPS)
2. ✅ Usa tokens con expiración
3. ✅ Cambia la SECRET_KEY en `.env`
4. ✅ Configura firewall solo para puertos necesarios

---

## 🆘 Solución de Problemas

### No puedo acceder al panel
```bash
# Verificar que los servicios estén corriendo
ssh root@72.62.86.94
docker-compose ps

# Ver logs
docker-compose logs web
```

### OBS no se conecta
```bash
# Verificar puerto RTMP
sudo ufw status | grep 1935

# Ver logs del servidor RTMP
docker-compose logs rtmp-server
```

### Stream no se ve
```bash
# Verificar que HLS esté generándose
ls -la /docker/streammaster-pro/data/streams/hls/

# Ver logs
docker-compose logs -f
```

---

**Servidor listo en:** `http://72.62.86.94` 🚀
