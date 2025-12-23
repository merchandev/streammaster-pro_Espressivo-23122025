# 🚀 Guía Completa de Despliegue Manual en VPS (Hostinger)

Esta guía contiene **todos los comandos necesarios** para preparar un VPS Ubuntu desde cero (recién instalado) y desplegar StreamMaster Pro.

---

## 🛠️ Fase 1: Preparación del Sistema (SSH)

Conéctate a tu VPS por SSH (Putty, Terminal, etc.):
```bash
ssh root@TU_IP_DEL_VPS
```

Copia y pega este bloque completo para instalar Docker y las herramientas necesarias:

```bash
# 1. Actualizar el sistema
apt update && apt upgrade -y

# 2. Instalar herramientas básicas
apt install -y git curl unzip ufw

# 3. Instalar Docker y Docker Compose (Script oficial)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 4. Configurar Firewall (UFW) para abrir los puertos necesarios
ufw allow 22/tcp    # SSH (IMPORTANTE para no bloquearse)
ufw allow 80/tcp    # Web Player
ufw allow 8080/tcp  # HLS Stream
ufw allow 1935/tcp  # RTMP OBS
ufw --force enable

# 5. Verificar instalación
echo "✅ Versión de Docker:"
docker --version
echo "✅ Versión de Docker Compose:"
docker compose version
```

---

## 📂 Fase 2: Subir el Proyecto

Tienes dos opciones para poner tu código en el servidor. Elige **UNA**:

### Opción A: Usando Git (Recomendado si tienes repositorio)

1. Crear directorio:
```bash
mkdir -p /docker/streammaster-pro
cd /docker/streammaster-pro
```

2. Clonar tu repositorio (reemplaza la URL):
```bash
# Si es privado, te pedirá usuario y token
git clone TU_URL_DEL_REPOSITORIO .
```

### Opción B: Subida Manual (SFTP / FileZilla)

Si tienes el código solo en tu PC:
1. Usa **FileZilla** o **WinSCP**.
2. Conecta a tu VPS con `root` y tu contraseña/clave.
3. Navega a la carpeta `/docker/` (creala si no existe).
4. Sube tu carpeta `streammaster-pro` completa ahí.
5. En la terminal SSH, entra a la carpeta:
```bash
cd /docker/streammaster-pro
```

---

## 🚀 Fase 3: Despliegue de Contenedores

Una vez que estás dentro de la carpeta `/docker/streammaster-pro` y tienes los archivos ahí:

```bash
# 1. Dar permisos de ejecución a scripts (opcional pero venía en tus notas)
chmod +x *.sh

# 2. Asegurar que no hay nada corriendo
docker compose down -v

# 3. Construir y levantar todo en segundo plano
docker compose up -d --build

# 4. Verificar que todo está corriendo
docker compose ps
```

Deberías ver algo así:
```
NAME                 STATUS
streammaster-rtmp    Up
streammaster-web     Up
```

---

## ✅ Fase 4: Verificación Final

Ejecuta estos comandos para asegurarte de que los puertos están escuchando:

```bash
netstat -tulpn | grep -E '80|8080|1935'
```

Si todo funciona:
1. **Streaming**: Configura OBS a `rtmp://TU_IP:1935/live` con clave `mistream`.
2. **Player**: Abre `http://TU_IP/` en tu navegador.

---

## 🆘 Comandos Útiles de Mantenimiento

**Ver logs en tiempo real:**
```bash
cd /docker/streammaster-pro && docker compose logs -f
```

**Reiniciar todo:**
```bash
cd /docker/streammaster-pro && docker compose restart
```

**Actualizar código (si usas Git):**
```bash
cd /docker/streammaster-pro
git pull
docker compose up -d --build
```
