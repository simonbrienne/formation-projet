FROM nginx:alpine

# Copier les fichiers de l'application
COPY ./frontend/dist /usr/share/nginx/html

ARG BACKEND_URL
ENV BACKEND_URL=$BACKEND_URL

# Copier le script d'entrée
COPY ./frontend/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Changer le point d'entrée
ENTRYPOINT ["/entrypoint.sh"]