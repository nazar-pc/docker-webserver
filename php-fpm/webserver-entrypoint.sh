#!/bin/bash
set -e

/webserver-common/ceph-mount.sh /data

# Automatic upgrade from older images
# TODO: remove in future
if [ -L /data/php/config ]; then
	rm /data/php/config
	mkdir /data/php/config
	mv /usr/local/etc/* /data/php/config
	sed -i 's/etc\/php-fpm.d/php-fpm.d/g' /data/php/config/php-fpm.conf
fi

if [ ! -e /data/php ]; then
	mkdir -p /data/php/config
	cp -a /usr/local/etc_dist/* /data/php/config/
fi

chown git:git /data /data/php
chown -R git:git /data/php/config

if [ "$1" = 'php-fpm' ]; then
	shift
fi

set -- -c /data/php/config --prefix /data/php/config --fpm-config /data/php/config/php-fpm.conf

if [ -e /data/php/before_start.sh ]; then
	bash /data/php/before_start.sh
else
	touch /data/php/before_start.sh
fi

export PHP_INI_DIR=/data/php/config
export PHP_INI_SCAN_DIR=/data/php/config/php/conf.d

exec php-fpm "$@"
