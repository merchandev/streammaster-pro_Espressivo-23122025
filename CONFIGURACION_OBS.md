# 📹 Guía de Configuración: OBS Studio

## Configuración Paso a Paso

### 1. Generar Token de Streaming

1. Abre el panel web de StreamMaster Pro: `http://TU-SERVIDOR`
2. Selecciona **OBS Studio** como encoder
3. Configura tu stream:
   - **Nombre:** Identifica tu stream
   - **Calidad:** 720p @ 30fps (recomendado) o 1080p
   - **Expiración:** 24 horas o según necesites
4. Click en **"Generar Token"**
5. **Guarda** la configuración mostrada

### 2. Configurar OBS

#### Ajustes de Emisión

1. Abre **OBS Studio**
2. Ve a **Archivo → Ajustes → Emisión**
3. Configura:
   - **Servicio:** `Personalizado`
   - **Servidor:** `rtmp://TU-IP:1935/live`
   - **Clave de emisión:** El token generado (ej: `abc123xyz...`)

#### Ajustes de Salida

1. Ve a **Ajustes → Salida**
2. **Modo de salida:** Avanzado
3. Pestaña **Streaming:**

**Para streaming a 720p @ 30fps (RECOMENDADO):**
```
Codificador de video: NVIDIA NVENC H.264 (o Hardware equivalente)
Aplicar ajustes del codificador: checked
Control de frecuencia: CBR
Bitrate: 3000 Kbps
Intervalo de fotogramas clave: 2 segundos
Preajuste: Calidad (Quality)
Perfil: high
Look-ahead: unchecked
Ajuste psicovisual: checked
```

**Para streaming a 1080p @ 30fps:**
```
Bitrate: 4500-6000 Kbps
Resto de configuración igual
```

#### Ajustes de Video

1. Ve a **Ajustes → Video**
2. Configura según tu calidad objetivo:

**Para 720p:**
```
Resolución base (lienzo): 1920x1080
Resolución de salida (escalada): 1280x720
Filtro de reducción de escala: Lanczos
FPS comunes: 30
```

**Para 1080p:**
```
Resolución base (lienzo): 1920x1080
Resolución de salida (escalada): 1920x1080
Filtro de reducción de escala: Lanczos
FPS comunes: 30
```

#### Ajustes de Audio

1. Ve a **Ajustes → Audio**
2. Configura:
```
Tasa de muestreo: 48 kHz
Canales: Estéreo
```

3. En **Salida → Audio:**
```
Pista de audio 1 - Bitrate: 160 kbps
Codificador: AAC
```

## Optimizaciones Avanzadas

### Para PC con GPU NVIDIA

```
Codificador: NVIDIA NVENC H.264
Preajuste: Max Quality
Perfil: high
Nivel: auto
Ajuste: Alta calidad
```

### Para PC con GPU AMD

```
Codificador: AMD HW H.264
Preajuste: Quality
Perfil: High
```

### Para PC con Intel QuickSync

```
Codificador: QuickSync H.264
Perfil objetivo: high
Nivel: auto
```

### Para PC sin GPU dedicada (software)

```
Codificador: x264
Uso de CPU: veryfast (o fast si tienes CPU potente)
Perfil: main
Ajuste: zerolatency
```

## Recomendaciones de Bitrate

| Calidad | Resolución | FPS | Bitrate Video | Bitrate Audio | Total |
|---------|------------|-----|---------------|---------------|-------|
| Baja    | 854x480    | 30  | 1500 Kbps     | 96 Kbps       | ~1.6 Mbps |
| Media   | 1280x720   | 30  | 3000 Kbps     | 128 Kbps      | ~3.1 Mbps |
| Alta    | 1920x1080  | 30  | 4500 Kbps     | 160 Kbps      | ~4.7 Mbps |
| Máxima  | 1920x1080  | 60  | 6000 Kbps     | 160 Kbps      | ~6.2 Mbps |

**IMPORTANTE:** Asegúrate de tener al menos **1.5x el bitrate** en velocidad de subida de internet.

## Checklist Pre-Stream

- [ ] Token generado y copiado
- [ ] Servidor RTMP configurado: `rtmp://TU-IP:1935/live`
- [ ] Clave de emisión configurada
- [ ] Bitrate apropiado para tu conexión
- [ ] Encoder por hardware habilitado (si es posible)
- [ ] Resolución de salida correcta
- [ ] FPS configurado a 30
- [ ] Test de conexión realizado

## Solución de Problemas

### "Failed to connect to server"

- Verifica que el servidor RTMP esté activo
- Comprueba el firewall (puerto 1935)
- Verifica la IP/dominio del servidor

### Stream se corta o tiene lag

- Reduce el bitrate
- Cambia a encoder por hardware
- Verifica tu velocidad de subida
- Reduce la resolución a 720p

### Calidad baja en el stream

- Aumenta el bitrate (hasta 6000 Kbps)
- Usa encoder por hardware (NVENC)
- Cambia preajuste a "Quality" o "Max Quality"
- Verifica que no estés escalando demasiado

### Audio desincronizado

- Cambia bitrate de audio a 160 o 128 Kbps
- Tasa de muestreo: 48 kHz
- Reinicia OBS

## Recursos Adicionales

- [Documentación oficial OBS](https://obsproject.com/kb/)
- [Calculadora de bitrate](https://www.omnicalculator.com/other/streaming-bitrate)
- [Test de velocidad](https://www.speedtest.net/)

---

**¿Necesitas ayuda?** Verifica los logs del servidor con `docker-compose logs -f rtmp-server`
