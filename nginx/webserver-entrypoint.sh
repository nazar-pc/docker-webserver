#!/bin/bash
set -e

/ceph-mount.sh \
	/data \
	/etc/nginx \
	/usr/share/nginx/html

if [ ! -e /etc/nginx/nginx.conf ]; then
	cp -a /etc/nginx_dist/* /etc/nginx/
fi

if [ ! -e /data/nginx ]; then
	mkdir -p /data/nginx
	ln -s /etc/nginx /data/nginx/config
	ln -s /var/log/nginx /data/nginx/log
	ln -s /usr/share/nginx/html /data/nginx/www
fi

chown git:git /data /usr/share/nginx/html /var/log/nginx
chown -R git:git /etc/nginx

# if command starts with an option, prepend nginx
if [ "${1:0:1}" = '-' ]; then
	set -- nginx "$@"
fi

if [ -e /data/nginx/before_start.sh ]; then
	bash /data/nginx/before_start.sh
else
	touch /data/nginx/before_start.sh
fi

exec "$@"
