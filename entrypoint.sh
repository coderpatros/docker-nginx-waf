#!/usr/bin/env bash

# make directory /var/log/nginx if needed
mkdir --parents /var/log/nginx

nginx -g "daemon off;"