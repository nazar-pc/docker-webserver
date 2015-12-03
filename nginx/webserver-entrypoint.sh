#!/bin/bash
set -e

if [ ! -f /etc/nginx/nginx.conf ]; then
	cp -a /etc/nginx_dist/* /etc/nginx/
	chown -R 1000:1000 /etc/nginx
fi

if [ ! -d /data/nginx ]; then
	mkdir -p /data/nginx
	chown 1000:1000 /data
	ln -s /etc/nginx /data/nginx/config
	ln -s /var/log/nginx /data/nginx/log
	ln -s /usr/share/nginx/html /data/nginx/www
	chown -R 1000:1000 /data/nginx
fi

/consul-dns.sh &

# if command starts with an option, prepend nginx
if [ "${1:0:1}" = '-' ]; then
	set -- nginx "$@"
fi

if [ -f /data/nginx/before_start.sh ]; then
	bash /data/nginx/before_start.sh
else
	touch /data/nginx/before_start.sh
fi

exec "$@"
