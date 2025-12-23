# ⚠️ IMPORTANTE: Este proyecto usa docker-compose.yml

## Para desplegar en producción:

```bash
# En el servidor
cd /docker/streammaster-pro
docker-compose down -v
docker-compose up -d --build
```

## NO usar docker-compose.hostinger.yml

Este archivo es solo un backup. El archivo principal es `docker-compose.yml`.
