#!/bin/sh
set -e

echo "[entrypoint] Preparing NGINX config..."
export ANTIVIRUS_API_KEY
envsubst '${ANTIVIRUS_API_KEY}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "[entrypoint] Starting original clamav startup command in the background..."
./usr/bin/entrypoint.sh &

echo "[entrypoint] Starting NGINX in the foreground..."
nginx -g 'daemon off;'