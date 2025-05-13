#!/bin/sh

# Remplacer les variables dans la configuration Nginx
envsubst '${USER_SERVICE_URL} ${TASK_SERVICE_URL} ${NOTIFICATION_SERVICE_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Démarrer Nginx
nginx -g 'daemon off;'