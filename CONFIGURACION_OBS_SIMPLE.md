# 🎥 Configuración OBS - StreamMaster Pro (Simplificado)

## 📡 Configuración Permanente

### Datos de Conexión (NO CAMBIAR)

```
Servidor RTMP: rtmp://72.62.86.94:1935/live
Clave de Stream: mistream
```

---

## 🔧 Pasos para Configurar OBS

### 1. Abrir Configuración de Emisión

1. Abrir **OBS Studio**
2. Ir a **Ajustes** (Settings)
3. Click en **Emisión** (Stream)

### 2. Configurar Servicio Personalizado

- **Servicio:** Personalizado (Custom)
- **Servidor:** `rtmp://72.62.86.94:1935/live`
   - **Clave de Transmisión (Stream Key):** `M0nagas_Live_Secure_2025`
   - **Autenticación:** Deshabilitada (dejar en blanco usuario/contraseña)

3. **Configuración de Salida (Output):**Ajustes → Salida → Transmisión:**

#### Configuración Recomendada (720p)

- **Encoder de video:** Hardware (NVENC) o x264
- **Aplicar tasa de bits máxima:** ✅ Activado
- **Tasa de bits:** `3500 Kbps`
- **Codificador preestablecido:** Quality
- **Perfil:** high
- **Intervalo de fotogramas clave:** `2`

#### Configuración Alta Calidad (1080p)

- **Encoder de video:** Hardware (NVENC) o x264
- **Aplicar tasa de bits máxima:** ✅ Activado
- **Tasa de bits:** `6000 Kbps`
- **Codificador preestablecido:** Quality
- **Perfil:** high
- **Intervalo de fotogramas clave:** `2`

### 4. Configurar Audio

En **Ajustes → Salida → Transmisión:**

- **Pista de audio:** 1
- **Tasa de bits de audio:** `160` o `192`

### 5. Configuración de Video (Resolución)

En **Ajustes → Video:**

#### Para 720p (Recomendado)
- **Resolución base (lienzo):** 1920x1080 (o tu resolución de pantalla)
- **Resolución de salida (escalada):** `1280x720`
- **FPS comunes:** `30`

#### Para 1080p
- **Resolución base (lienzo):** 1920x1080
- **Resolución de salida (escalada):** `1920x1080`
- **FPS comunes:** `30` o `60` (si tu PC lo soporta)

---

## 🎬 Iniciar Transmisión

1. Configurar tus **Fuentes** (cámara, pantalla, etc.)
2. Click en **Iniciar transmisión**
3. Esperar 10-15 segundos para que el stream se estabilice
4. Abrir en el navegador: **http://72.62.86.94/**

✅ ¡El video debería aparecer automáticamente!

---

## 🌐 Ver el Streaming

### URL Permanente del Player

```
http://72.62.86.94/
```

Esta URL es **permanente** y siempre mostrará tu stream cuando estés transmitiendo.

### Compartir el Stream

Puedes compartir directamente esta URL con quien quieras que vea el stream:
- No necesitan configurar nada
- Solo abrir el link en su navegador
- Compatible con: Chrome, Firefox, Safari, Edge

---

## 🎯 Ajustes Avanzados (Opcional)

### Para Reducir Latencia

En **Ajustes → Avanzado:**

- **Flujo de procesos:** Baja latencia
- **Retardo de reconexión:** 1 segundo
- **Intentos máximos de reintento:** 3

### Para Optimizar Calidad

En **Ajustes → Salida → Transmisión:**

- **Preajuste de codificador:** Max Quality
- **Ajuste:** `zerolatency` o `ultrafast` (depende del CPU)
- **Perfil:** `high`

---

## ⚙️ Tabla de Referencia de Bitrates

| Resolución | FPS | Bitrate Video | Bitrate Audio | Total |
|------------|-----|---------------|---------------|-------|
| 480p | 30 | 1500 Kbps | 128 Kbps | ~1630 Kbps |
| 720p | 30 | 3500 Kbps | 160 Kbps | ~3660 Kbps |
| 720p | 60 | 5000 Kbps | 160 Kbps | ~5160 Kbps |
| 1080p | 30 | 6000 Kbps | 192 Kbps | ~6192 Kbps |
| 1080p | 60 | 9000 Kbps | 192 Kbps | ~9192 Kbps |

**Recomendación:** Usa 720p @ 30fps con 3500 Kbps para mejor balance calidad/estabilidad.

---

## 🚨 Troubleshooting

### OBS no se conecta

1. Verificar que el servidor está corriendo
2. Verificar que usas `rtmp://` NO `rtmps://`
3. Verificar que la clave es exactamente: `mistream`
4. Verificar firewall/antivirus no bloquea el puerto 1935

### El stream se corta

1. Reducir el bitrate (ejemplo: de 6000 a 3500)
2. Cambiar encoder preset a "Fast" o "Ultrafast"
3. Verificar tu conexión de internet (upload speed)

### La calidad es mala

1. Aumentar el bitrate (sin exceder tu upload speed)
2. Cambiar preset a "Quality" o "Max Quality"  
3. Verificar que la resolución de salida es correcta

---

## 📊 Verificar que el Stream Funciona

### Desde OBS

En la parte inferior de OBS, deberías ver:
- **Transmitiendo:** ✅ En verde
- **Tasa de bits:** Mostrando kbps activo
- **Fotogramas perdidos:** 0% o muy bajo (<0.5%)

### Desde el Navegador

1. Abrir: http://72.62.86.94/
2. Esperar 5-10 segundos
3. El video debería aparecer automáticamente

### Desde el Servidor (SSH)

```bash
ssh root@72.62.86.94
docker logs streammaster-rtmp --tail=20
```

Deberías ver:
```
[info] ... create: client publishing 'mistream' ...
```

---

## 📞 Soporte

Si tienes problemas:

1. Captura de pantalla de la configuración de OBS
2. Logs del servidor: `docker logs streammaster-rtmp`
3. Screenshot de errores en consola del navegador (F12)

---

## ✅ Checklist de Configuración

- [ ] Servicio configurado como "Personalizado"
- [ ] Servidor: `rtmp://72.62.86.94:1935/live`
- [ ] Clave: `mistream`
- [ ] Bitrate configurado (3500-6000 kbps)
- [ ] Resolución de salida configurada (720p o 1080p)
- [ ] FPS configurado (30 o 60)
- [ ] Audio configurado (160 kbps)
- [ ] Test de transmisión realizado
- [ ] URL del player funciona: http://72.62.86.94/

---

**🎉 ¡Listo! Tu configuración es permanente, no necesitas cambiar nada más.**
