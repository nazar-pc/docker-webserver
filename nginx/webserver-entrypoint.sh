#!/bin/bash
set -e

/consul-dns.sh &

# if command starts with an option, prepend nginx
if [ "${1:0:1}" = '-' ]; then
	set -- nginx "$@"
fi

if [ "$1" = 'nginx' ]; then
	if [ ! -f /etc/nginx/nginx.conf ]; then
		mkdir -p /etc/nginx
		cp -a /etc/nginx_dist/* /etc/nginx/
		chown -R 1000:1000 /etc/nginx
	fi

	if [ -f /data/nginx/before_start.sh ]; then
		bash /data/nginx/before_start.sh
	else
		touch /data/nginx/before_start.sh
	fi
fi

exec "$@"
