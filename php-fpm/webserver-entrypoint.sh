#!/bin/bash
set -e

# if command starts with an option, prepend php-fpm
if [ "${1:0:1}" = '-' ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ]; then
	if [ ! -f /usr/local/etc/php-fpm.conf ]; then
		mkdir -p /usr/local/etc/
		chown -R 1000:1000 /usr/local/etc
		cp -a /usr/local/etc_dist/* /usr/local/etc/
	fi

	if [ -f /data/php/before_start.sh ]; then
		bash /data/php/before_start.sh
	fi
fi

exec "$@"
