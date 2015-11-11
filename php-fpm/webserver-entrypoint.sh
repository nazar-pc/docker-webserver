#!/bin/bash

if [ ! -f /usr/local/etc/php-fpm.conf ]; then
	mkdir -p /usr/local/etc/
	chown -R 1000:1000 /usr/local/etc
	cp -a /usr/local/etc_dist/* /usr/local/etc/
fi

if [ -f /data/nginx/before_start.sh ]; then
	bash /data/nginx/before_start.sh
fi

set -e

exec php-fpm
