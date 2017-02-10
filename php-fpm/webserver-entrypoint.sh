#!/bin/bash
set -e

/ceph-mount.sh \
	/data \
	/usr/local/etc

if [ ! -e /data/php ]; then
	mkdir -p /data/php
	ln -s /usr/local/etc /data/php/config
fi

if [ ! -e /usr/local/etc/php-fpm.conf ]; then
	cp -a /usr/local/etc_dist/* /usr/local/etc/
fi

chown git:git /data
chown -R git:git /data/php /usr/local/etc

if [ -e /data/php/before_start.sh ]; then
	bash /data/php/before_start.sh
else
	touch /data/php/before_start.sh
fi

# if command starts with an option, prepend php-fpm
if [ "${1:0:1}" = '-' ]; then
	set -- php-fpm "$@"
fi

exec "$@"
