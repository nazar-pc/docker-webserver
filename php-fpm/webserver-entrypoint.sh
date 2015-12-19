#!/bin/bash
set -e

/consul-dns.sh &

/ceph-mount.sh \
	/data \
	/usr/local/etc

if [ ! -e /data/php ]; then
	mkdir -p /data/php
	chown 1000:1000 /data
	chown -R 1000:1000 /data/php
	ln -s /usr/local/etc /data/php/config
fi

# if command starts with an option, prepend php-fpm
if [ "${1:0:1}" = '-' ]; then
	set -- php-fpm "$@"
fi

if [ ! -e /usr/local/etc/php-fpm.conf ]; then
	cp -a /usr/local/etc_dist/* /usr/local/etc/
	chown -R 1000:1000 /usr/local/etc
fi

if [ -e /data/php/before_start.sh ]; then
	bash /data/php/before_start.sh
else
	touch /data/php/before_start.sh
fi

exec "$@"
