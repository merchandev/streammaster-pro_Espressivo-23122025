<?php
/**
 * Plugin Name: StreamMaster Pro Player
 * Plugin URI: https://monagasvision.com
 * Description: Integración oficial del reproductor StreamMaster Pro. Usa el shortcode [streammaster] en cualquier página.
 * Version: 2.0
 * Author: StreamMaster Dev
 * License: GPL2
 */

if (!defined('ABSPATH')) {
    exit;
}

function streammaster_player_shortcode($atts) {
    // Configuración por defecto
    $atts = shortcode_atts(array(
        'width' => '100%',
        'height' => '500px',
    ), $atts);

    // Detección inteligente de protocolo
    // Si la web es HTTPS, FORZAMOS el uso del dominio seguro
    if (is_ssl()) {
        $stream_url = "https://tv.monagasvision.com/player.html";
        $protocol_msg = "";
    } else {
        // Si es HTTP, podemos usar la IP directa (aunque el dominio seguro también valdría)
        // Usamos la IP para máxima compatibilidad legacy
        $stream_url = "http://72.62.86.94/player.html";
        $protocol_msg = "<!-- Modo HTTP detectado -->";
    }

    $html = '
    <div class="streammaster-container" style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.3);">
        <iframe 
            src="' . esc_url($stream_url) . '" 
            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none;" 
            allow="autoplay; fullscreen; picture-in-picture" 
            allowfullscreen>
        </iframe>
    </div>' . $protocol_msg;

    return $html;
}

add_shortcode('streammaster', 'streammaster_player_shortcode');
