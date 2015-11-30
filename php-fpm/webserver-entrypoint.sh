#!/bin/bash
set -e

if [ ! -d /data/php ]; then
	mkdir -p /data/php
	chown 1000:1000 /data
	chown -R 1000:1000 /data/php
	ln -s /usr/local/etc /data/php/config
fi

/consul-dns.sh &

# if command starts with an option, prepend php-fpm
if [ "${1:0:1}" = '-' ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ]; then
	if [ ! -f /usr/local/etc/php-fpm.conf ]; then
		mkdir -p /usr/local/etc/
		cp -a /usr/local/etc_dist/* /usr/local/etc/
		chown -R 1000:1000 /usr/local/etc
	fi

	if [ -f /data/php/before_start.sh ]; then
		bash /data/php/before_start.sh
	else
		touch /data/php/before_start.sh
	fi
fi

exec "$@"
