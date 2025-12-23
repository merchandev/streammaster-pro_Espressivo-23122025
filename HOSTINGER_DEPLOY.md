# StreamMaster Pro - Despliegue en Hostinger

## ⚠️ Problema Detectado

Hostinger no puede montar archivos individuales de configuración. Necesitas uno de estos métodos:

## ✅ Método 1: Usar Imagen Docker Pre-construida (RECOMENDADO)

### Paso 1: Construir imagen personalizada

Crea un `Dockerfile` para el servidor RTMP:

```dockerfile
FROM tiangolo/nginx-rtmp

# Copiar configuración personalizada
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Crear directorios
RUN mkdir -p /tmp/streams/hls
```

### Paso 2: Subir a Docker Hub

```bash
docker build -t tu-usuario/streammaster-rtmp:latest .
docker push tu-usuario/streammaster-rtmp:latest
```

### Paso 3: Modificar docker-compose.yml

```yaml
rtmp-server:
  image: tu-usuario/streammaster-rtmp:latest  # Tu imagen personalizada
  # ... resto de configuración
```

## ✅ Método 2: Usar docker-compose.hostinger.yml

He creado un archivo `docker-compose.hostinger.yml` simplificado. 

**Úsalo en lugar del docker-compose.yml normal:**

1. Renombra en GitHub:
```bash
git mv docker-compose.yml docker-compose.local.yml
git mv docker-compose.hostinger.yml docker-compose.yml
git commit -m "Use Hostinger-compatible docker-compose"
git push
```

2. O especifica el archivo en Hostinger:
```bash
docker-compose -f docker-compose.hostinger.yml up -d
```

## ✅ Método 3: Configuración Manual (Más Simple)

1. **Conéctate por SSH a tu VPS de Hostinger**

2. **Navega al directorio del proyecto:**
```bash
cd /docker/streammaster-pro
```

3. **Crea los directorios necesarios:**
```bash
mkdir -p nginx data/streams logs/nginx
chmod +x init-config.sh
./init-config.sh
```

4. **Verifica que los archivos existan:**
```bash
ls -la nginx/
# Debes ver: nginx.conf y web.conf
```

5. **Ahora sí, despliega:**
```bash
docker-compose up -d
```

## 🔍 Verificar que Funciona

```bash
# Ver servicios activos
docker-compose ps

# Ver logs
docker-compose logs -f

# Probar conexión RTMP
curl http://localhost:8080/stat
```

## 📝 Checklist

- [ ] Todos los archivos subidos a GitHub
- [ ] Directorio `nginx/` existe con archivos .conf
- [ ] Archivo `.env` creado con SECRET_KEY
- [ ] Script `init-config.sh` ejecutado
- [ ] docker-compose up ejecutado sin errores
- [ ] Puerto 1935 y 80 abiertos en firewall

## 🆘 Si Siguen los Errores

Compárteme el output completo de:

```bash
ls -laR /docker/streammaster-pro/nginx/
cat /docker/streammaster-pro/docker-compose.yml
```

Y te ayudo a resolverlo.
