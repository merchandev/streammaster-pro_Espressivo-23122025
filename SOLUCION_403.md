# 🚨 SOLUCIÓN RÁPIDA - Error 403 Forbidden

## ❌ Problema Identificado

Tu servicio `streammaster-web` está mostrando **403 Forbidden** porque nginx no encuentra los archivos del frontend.

```
Error: directory index of "/usr/share/nginx/html/" is forbidden
```

![Error 403 en navegador](C:/Users/merch/.gemini/antigravity/brain/36e07a04-33c4-4ae4-b021-8fdf2941b82e/uploaded_image_1766527873132.png)

---

## ✅ Solución en 3 Pasos

### Opción 1: Script Automático (Recomendado) 🚀

Ejecuta este script en tu servidor:

```bash
# Conéctate al servidor
ssh root@72.62.86.94

# Ve al directorio del proyecto
cd /docker/streammaster-pro

# Ejecuta el script de reparación
chmod +x deploy-fix.sh
./deploy-fix.sh
```

Este script:
- ✅ Verifica que todos los archivos existen
- ✅ Detiene y limpia servicios anteriores
- ✅ Reconstruye las imágenes
- ✅ Monta la configuración nginx correcta
- ✅ Valida que todo funcione

---

### Opción 2: Comandos Manuales 🔧

Si prefieres hacerlo paso a paso:

```bash
# Conéctate al servidor
ssh root@72.62.86.94

# Ve al directorio del proyecto  
cd /docker/streammaster-pro

# 1. Detener el contenedor web problemático
docker stop streammaster-web
docker rm streammaster-web

# 2. Verificar que los archivos existen
ls -la frontend/
# Deberías ver: index.html, player.html, style.css

# 3. Verificar permisos
chmod -R 755 frontend/

# 4. Reiniciar el servicio
docker-compose up -d web

# 5. Verificar archivos en el contenedor
docker exec streammaster-web ls -lah /usr/share/nginx/html/

# 6. Ver logs
docker logs streammaster-web --tail 30

# 7. Probar acceso
curl -I http://localhost
```

---

### Opción 3: Solo Reparar Web (Más Rápido) ⚡

Si solo quieres arreglar el servicio web:

```bash
# Conéctate al servidor
ssh root@72.62.86.94

# Ve al directorio del proyecto
cd /docker/streammaster-pro

# Ejecuta el script de reparación rápida
chmod +x fix-web.sh
./fix-web.sh
```

---

## 🔍 Verificar que Funciona

Después de ejecutar cualquiera de las opciones, verifica:

### 1. Desde el navegador:
```
http://72.62.86.94
```

Deberías ver el panel de StreamMaster Pro con:
- 🎬 Logo y título "StreamMaster Pro"
- ⚡ Features: Ultra Baja Latencia, RTMP Compatible, Alta Estabilidad
- ▶ Botón "Ver Streaming en Vivo"
- ⚙ Sección de configuración

### 2. Desde el servidor (SSH):
```bash
curl http://localhost
```

Deberías ver el HTML del index.html

### 3. Ver el player:
```
http://72.62.86.94/player.html
```

---

## 🎯 ¿Qué se Arregló?

Los cambios aplicados:

### 1. **Configuración nginx personalizada** (`nginx/web.conf`)
   - Especifica correctamente el `root` y el `index`
   - Agrega CORS headers
   - Habilita logs mejorados

### 2. **Docker Compose actualizado** (`docker-compose.yml`)
   - Ahora monta correctamente `./nginx/web.conf` en el contenedor
   - Sobrescribe la configuración por defecto de nginx

### 3. **Scripts de diagnóstico y reparación**
   - `fix-web.sh` - Reparación rápida del servicio web
   - `deploy-fix.sh` - Despliegue completo con validaciones

---

## 📋 Archivos Modificados

1. ✏️ [`nginx/web.conf`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/nginx/web.conf) - Configuración nginx simplificada
2. ✏️ [`docker-compose.yml`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/docker-compose.yml) - Monta web.conf correctamente
3. ➕ [`fix-web.sh`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/fix-web.sh) - Script de reparación rápida
4. ➕ [`deploy-fix.sh`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/deploy-fix.sh) - Script de despliegue completo
5. ✏️ [`TROUBLESHOOTING.md`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/TROUBLESHOOTING.md) - Documentación actualizada

---

## 🆘 Si Aún No Funciona

### Verificar firewall:
```bash
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw reload
```

### Verificar que no hay otro servicio en puerto 80:
```bash
sudo netstat -tulpn | grep :80
```

### Ver logs detallados:
```bash
docker logs streammaster-web --tail 100
docker exec streammaster-web cat /var/log/nginx/error.log
```

### Reconstruir desde cero:
```bash
docker-compose down -v
docker-compose up -d --build
```

---

## 📞 Próximos Pasos

Una vez que el panel web funcione, puedes:

1. **Configurar OBS/vMix:**
   - Servidor: `rtmp://72.62.86.94:1935/live`
   - Clave: `mistream`

2. **Ver el streaming:**
   - Player: `http://72.62.86.94/player.html`
   - HLS directo: `http://72.62.86.94:8080/hls/mistream.m3u8`

3. **Monitorear logs:**
   ```bash
   docker-compose logs -f
   ```

---

## 📚 Documentación Adicional

- [`TROUBLESHOOTING.md`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/TROUBLESHOOTING.md) - Guía completa de troubleshooting
- [`DESPLIEGUE_SIMPLE.md`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/DESPLIEGUE_SIMPLE.md) - Instrucciones de despliegue
- [`CONFIGURACION_OBS_SIMPLE.md`](file:///c:/Users/merch/.gemini/antigravity/scratch/streammaster-pro/CONFIGURACION_OBS_SIMPLE.md) - Configurar OBS

---

**¿Necesitas ayuda?** Comparte:
- Los logs: `docker logs streammaster-web --tail 50`
- El resultado de: `docker exec streammaster-web ls -lah /usr/share/nginx/html/`
