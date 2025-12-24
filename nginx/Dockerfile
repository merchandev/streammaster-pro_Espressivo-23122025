FROM tiangolo/nginx-rtmp:latest

# Crear directorio para streams con permisos amplios
RUN mkdir -p /tmp/streams/hls && chmod -R 777 /tmp/streams

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY stat.xsl /usr/local/nginx/html/stat.xsl

# Asegurar permisos de configuración
RUN chmod 644 /etc/nginx/nginx.conf

# Exponer puertos
EXPOSE 1935 80

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"]
