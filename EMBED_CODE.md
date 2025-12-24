# StreamMaster Pro - Embed Code

Aquí tienes el código para insertar el reproductor en **monagasvision.com**.

## Código Iframe (Copia y Pega esto)

Este código es **responsivo**, lo que significa que se adaptará automáticamente al tamaño de la pantalla (móvil, tablet, escritorio) manteniendo la proporción correcta del video (16:9).

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

## Instrucciones para WordPress / Elementor

1.  Añade un bloque de **HTML Personalizado** (Custom HTML).
2.  Pega el código de arriba dentro del bloque.
3.  Guarda o actualiza la página.

## Características
-   **Autoplay**: Intentará reproducir automáticamente (silenciado) gracias al atributo `allow="autoplay"`.
-   **Pantalla Completa**: Permitirá expandir el video con `allowfullscreen`.
-   **Responsivo**: Se ajusta al ancho de la columna donde lo pongas.
