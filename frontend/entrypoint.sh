#!/bin/sh

# Remplacer le placeholder BACKEND_URL dans le fichier HTML par la valeur de la variable d'environnement
if [ -n "$BACKEND_URL" ]; then
    sed -i "s|__BACKEND_URL__|$BACKEND_URL|g" /usr/share/nginx/html/index.html
fi

# Démarrer Nginx
exec nginx -g 'daemon off;'