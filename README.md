# 🎬 StreamMaster Pro v2.0

Sistema de streaming profesional RTMP → HLS con ultra-baja latencia (3-5 segundos).

## ✨ Características

- ⚡ **Ultra Baja Latencia**: 3-5 segundos de retraso
- 🎥 **Compatible con OBS/vMix**: RTMP standard
- 🚀 **Alta Estabilidad**: Sin caídas ni buffering
- 📱 **Responsive**: Funciona en móviles, tablets y desktop
- 🔧 **Sin Backend**: Solo Nginx RTMP + Frontend estático
- 🐳 **Dockerizado**: Despliegue en segundos

## 📦 Arquitectura Simplificada

```
OBS/vMix → RTMP (Puerto 1935) → Nginx RTMP → HLS (Puerto 8080) → Player Web (Puerto 80)
```

## 🚀 Despliegue Rápido

### Opción 1: Script Automatizado (Recomendado)

```bash
ssh root@72.62.86.94
cd /docker/streammaster-pro
chmod +x deploy.sh
./deploy.sh
```

### Opción 2: Manual

```bash
ssh root@72.62.86.94
cd /docker/streammaster-pro
git pull origin main
docker-compose -f docker-compose.hostinger.yml down
docker-compose -f docker-compose.hostinger.yml up -d --build
```

## 📡 Configuración de OBS

1. **Servicio**: Personalizado
2. **Servidor**: `rtmp://72.62.86.94:1935/live`
3. **Clave**: `mistream`
4. **Bitrate**: 3000-5000 kbps
5. **Keyframe**: 2 segundos

## 🎯 Acceso

- **Página Principal**: http://72.62.86.94
- **Player en Vivo**: http://72.62.86.94/player.html
- **Estadísticas RTMP**: http://72.62.86.94:8080/stat

## 📁 Estructura del Proyecto

```
streammaster-pro/
├── frontend/                    # Frontend estático
│   ├── index.html              # Página principal
│   ├── player.html             # Player HLS
│   └── style.css               # Estilos
├── nginx/
│   ├── nginx.conf              # Configuración RTMP+HLS
│   └── Dockerfile              # Imagen nginx-rtmp
├── docker-compose.hostinger.yml # Docker Compose para VPS
├── deploy.sh                    # Script de despliegue
├── DESPLIEGUE.md               # Guía detallada
└── README.md                   # Este archivo
```

## 🔧 Servicios Docker

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| `streammaster-rtmp` | 1935 | Servidor RTMP (entrada desde OBS) |
| `streammaster-rtmp` | 8080 | Servidor HLS (salida de video) |
| `streammaster-web` | 80 | Frontend estático (player) |

## 🐛 Troubleshooting

### Error 403 Forbidden

```bash
chmod -R 755 frontend/
docker-compose -f docker-compose.hostinger.yml restart web
```

### No se conecta RTMP

```bash
sudo ufw allow 1935/tcp
docker-compose -f docker-compose.hostinger.yml logs rtmp-server
```

### Player muestra "Offline"

1. Verificar que OBS esté transmitiendo
2. Verificar que la stream key sea `mistream`
3. Ver logs: `docker-compose -f docker-compose.hostinger.yml logs -f`

## 📊 Monitoreo

```bash
# Ver logs en tiempo real
docker-compose -f docker-compose.hostinger.yml logs -f

# Ver estado de servicios
docker-compose -f docker-compose.hostinger.yml ps

# Ver uso de recursos
docker stats
```

## 📝 Cambios en v2.0

- ✅ Eliminado sistema de backend API
- ✅ Eliminado chat/websockets
- ✅ Frontend completamente estático
- ✅ Simplificación de código
- ✅ Mejor manejo de errores en player
- ✅ Reconexión automática mejorada
- ✅ Interfaz moderna y responsive

## 📖 Documentación Completa

Ver [DESPLIEGUE.md](DESPLIEGUE.md) para instrucciones detalladas.

## 🆘 Soporte

Si tienes problemas, revisa los logs:

```bash
docker-compose -f docker-compose.hostinger.yml logs -f
```

## 📄 Licencia

MIT License - Uso libre para proyectos personales y comerciales.

---

**StreamMaster Pro v2.0** - Streaming profesional simplificado
