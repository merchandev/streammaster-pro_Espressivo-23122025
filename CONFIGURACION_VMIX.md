# 🎚️ Guía de Configuración: vMix

## Configuración Paso a Paso

### 1. Generar Token de Streaming

1. Abre el panel web de StreamMaster Pro: `http://TU-SERVIDOR`
2. Selecciona **vMix** como encoder
3. Configura:
   - **Nombre del stream:** Identifica tu transmisión
   - **Calidad:** 720p @ 30fps (recomendado)
   - **Expiración:** 24 horas o según necesites
4. Click en **"Generar Token"**
5. **Copia** la configuración generada o descarga el archivo JSON

### 2. Configurar vMix

#### Método 1: Configuración Manual

1. Abre **vMix**
2. Click en **Settings** (⚙️ arriba a la derecha)
3. Ve a la pestaña **Outputs / NDI / SRT**
4. En la sección **Stream**, click en **Streaming Settings**

Configura los siguientes valores:

```
Stream Type: RTMP
Name/Description: StreamMaster Pro
Server: rtmp://TU-IP:1935/live
Stream Name/Key: [TOKEN GENERADO]
Quality: [Selecciona según tu configuración]
Framerate: 30fps
```

#### Método 2: Importar Configuración JSON

1. Descarga el archivo JSON del panel web
2. En vMix, ve a **Settings → Outputs**
3. Click en **Import** y selecciona el archivo JSON descargado
4. Verifica que todos los campos estén correctos

### 3. Configuración de Calidad de Video

#### Para 720p @ 30fps (RECOMENDADO)

```
Resolution: 1280x720
Framerate: 30fps
Video Bitrate: 3000-4500 kbps
Keyframe Interval: 2 seconds
Encoder: Hardware (NVIDIA/AMD/Intel)
Quality: High
Profile: High
```

#### Para 1080p @ 30fps

```
Resolution: 1920x1080
Framerate: 30fps
Video Bitrate: 4500-6000 kbps
Keyframe Interval: 2 seconds
Encoder: Hardware
Quality: High
Profile: High
```

### 4. Configuración de Audio

```
Audio Bitrate: 128 kbps (o 192 kbps para mejor calidad)
Sample Rate: 48000 Hz
Channels: Stereo
Audio Format: AAC
```

## Ajustes Óptimos por Hardware

### GPU NVIDIA

```
Encoder: NVIDIA NVENC
Preset: High Quality
Profile: High
Latency Mode: Normal
```

### GPU AMD

```
Encoder: AMD VCE
Quality Preset: Quality
Profile: High
```

### Intel QuickSync

```
Encoder: Intel QuickSync
Target Usage: Quality
Profile: High
```

### CPU (Software - si no tienes GPU)

```
Encoder: x264
Preset: Fast
Profile: Main
⚠️ NOTA: Consume más CPU, solo para equipos potentes
```

## Tabla de Bitrates Recomendados

| Resolución | FPS | Bitrate Video | Bitrate Audio | Velocidad de Subida Mínima |
|------------|-----|---------------|---------------|----------------------------|
| 480p       | 30  | 1500 kbps     | 96 kbps       | 2.5 Mbps                   |
| 720p       | 30  | 3000 kbps     | 128 kbps      | 5 Mbps                     |
| 720p       | 60  | 4500 kbps     | 128 kbps      | 7 Mbps                     |
| 1080p      | 30  | 4500 kbps     | 128 kbps      | 7 Mbps                     |
| 1080p      | 60  | 6000 kbps     | 192 kbps      | 10 Mbps                    |

## Configuración Adicional en vMix

### Activar Streaming

1. Una vez configurado, verás el botón **Stream** en la interfaz principal
2. Click en el dropdown junto a Stream
3. Selecciona tu configuración de StreamMaster Pro
4. Click en **Stream** para iniciar

### Monitoreo en vMix

Durante el streaming puedes ver:
- **FPS actual** (debe ser estable en 30 o 60)
- **Bitrate** (debe ser consistente)
- **Dropped frames** (debe ser 0% o muy bajo < 1%)

### Estadísticas y Diagnóstico

1. Click derecho en el botón **Stream**
2. Selecciona **Statistics**
3. Verifica:
   - Connection: Debe estar "Connected"
   - Frames dropped: Debe ser 0% o < 1%
   - Bitrate: Debe ser estable

## Configuración Avanzada

### Para Streaming de Alta Calidad (1080p60)

```json
{
  "StreamType": "RTMP",
  "Server": "rtmp://TU-IP:1935/live",
  "StreamKey": "TU-TOKEN",
  "VideoBitrate": 6000,
  "AudioBitrate": 192,
  "Resolution": "1920x1080",
  "Framerate": 60,
  "Encoder": "NVIDIA NVENC",
  "Preset": "High Quality",
  "Profile": "High",
  "Keyframe": 2
}
```

### Para Streaming de Baja Latencia

```
Enable Low Latency Mode: Yes
Keyframe Interval: 1 segundo
Buffer: Reducido
```

## Multi-Streaming (Bonus)

vMix permite hacer streaming a múltiples destinos simultáneamente:

1. Configura StreamMaster Pro como destino principal
2. Añade destinos adicionales (YouTube, Facebook, etc.)
3. En **Settings → Outputs**, agrega nuevos streams
4. Todos se activarán al presionar el botón Stream

## Checklist Pre-Stream

- [ ] Token generado y configurado
- [ ] Servidor: `rtmp://TU-IP:1935/live`
- [ ] Stream Key ingresada correctamente
- [ ] Bitrate apropiado para tu conexión
- [ ] Encoder por hardware seleccionado
- [ ] Resolución y FPS configurados
- [ ] Audio bitrate configurado (128+ kbps)
- [ ] Test de conexión exitoso

## Solución de Problemas

### "Connection Failed" o "Could not connect"

**Causas comunes:**
- Servidor RTMP no está activo
- Firewall bloqueando puerto 1935
- IP/dominio incorrecto
- Token inválido o expirado

**Soluciones:**
```bash
# En el servidor, verifica que Docker esté corriendo
docker-compose ps

# Verifica que el puerto 1935 esté abierto
sudo ufw status

# Ver logs del servidor RTMP
docker-compose logs rtmp-server
```

### Frames Dropped Alto (> 5%)

**Causas:**
- Bitrate muy alto para tu conexión
- CPU/GPU sobrecargado
- Problemas de red

**Soluciones:**
- Reduce el bitrate de video
- Baja la resolución a 720p
- Cambia a encoder por hardware
- Cierra programas innecesarios
- Conecta por cable ethernet (no WiFi)

### Audio/Video Desincronizado

**Soluciones:**
- Reinicia vMix
- Verifica que Audio Bitrate sea 128+ kbps
- Sample Rate: 48000 Hz
- Desactiva "Audio Delay" si está habilitado

### Calidad Baja en el Stream

**Soluciones:**
- Aumenta el bitrate (hasta 6000 kbps para 1080p)
- Cambia Quality preset a "High" o "Ultra"
- Usa encoder por hardware (NVENC, QuickSync)
- Verifica que no estés escalando la resolución incorrectamente

### Stream se Detiene Aleatoriamente

**Causas:**
- Conexión a internet inestable
- Token expirado
- Servidor sobrecargado

**Soluciones:**
- Genera un nuevo token con más tiempo de expiración
- Verifica tu conexión con speedtest
- Contacta con tu proveedor de internet
- Reduce calidad temporalmente

## Tips Profesionales

### 1. Configuración de Backup
Configura un servidor de respaldo en caso de fallas:
- Settings → Outputs → Add Stream
- Configura un segundo servidor
- Activa "Failover" mode

### 2. Grabación Simultánea
- Settings → Recording
- Activa grabación local mientras haces streaming
- Calidad: Igual o superior al stream

### 3. Reducir Latencia
- Keyframe: 1 segundo (en lugar de 2)
- Desactiva buffer adicional
- Usa conexión ethernet

### 4. Monitoreo en Tiempo Real
- Mantén la ventana Statistics abierta
- Observa dropped frames
- Verifica bitrate estable

## Recursos Adicionales

- [Documentación oficial vMix](https://www.vmix.com/help/)
- [Calculadora de bitrate](https://www.vmix.com/software/calculator.aspx)
- [Test de velocidad](https://www.speedtest.net/)
- [Foro de soporte vMix](https://forums.vmix.com/)

## Configuraciones Preestablecidas

### Gaming (1080p60)
```
Resolution: 1920x1080 @ 60fps
Video Bitrate: 6000 kbps
Audio Bitrate: 160 kbps
Encoder: NVIDIA NVENC
Profile: High
```

### Eventos Corporativos (1080p30)
```
Resolution: 1920x1080 @ 30fps
Video Bitrate: 4500 kbps
Audio Bitrate: 192 kbps
Encoder: Hardware disponible
Profile: High
```

### Streaming Móvil/4G (720p30)
```
Resolution: 1280x720 @ 30fps
Video Bitrate: 2500 kbps
Audio Bitrate: 96 kbps
Encoder: Hardware
Profile: Main
```

---

**¿Problemas?** Revisa los logs del servidor: `docker-compose logs -f rtmp-server`
