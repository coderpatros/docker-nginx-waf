#!/usr/bin/env bash

# make directory /var/log/nginx if needed
mkdir --parents /var/log/nginx

service cron start

# Launch NGINX
echo "starting nginx ..."
nginx -g "daemon off;" &

nginx_pid=$!
wait ${nginx_pid}

echo "nginx master process has stopped, exiting."