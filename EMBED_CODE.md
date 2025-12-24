# StreamMaster Pro - Código de Integración para WordPress

Aquí tienes el código **actualizado** para tu página web.

¡IMPORTANTE!: Como tu página **monagasvision.com** es segura (tiene candadito), necesitas usar la **Opción 1**.

---

## Opción 1: Código Seguro (Recomendado) 🔒
**Úsalo si ya activaste el SSL en el servidor.**

```html
<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
    <iframe 
        src="https://tv.monagasvision.com/player.html" 
        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" 
        frameborder="0" 
        allow="autoplay; fullscreen; picture-in-picture" 
        allowfullscreen>
    </iframe>
</div>
```

---

## Opción 2: Código Básico (Solo IP) ⚠️
**Solo úsalo si tu página NO tiene candadito (es http).**

```html
<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000;">
    <iframe 
        src="http://72.62.86.94/player.html" 
        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" 
        frameborder="0" 
        allow="autoplay; fullscreen; picture-in-picture" 
        allowfullscreen>
    </iframe>
</div>
```

---

## Instrucciones para WordPress

1.  Edita la página donde quieres el video.
2.  Busca el bloque **"HTML Personalizado"**.
3.  Copia y pega el código de la **Opción 1**.
4.  Si no se ve el video, asegúrate de haber ejecutado `./enable_ssl.sh` en el servidor.
