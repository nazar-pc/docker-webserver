#!/bin/bash
set -e

/webserver-common/ceph-mount.sh /data

# Automatic upgrade from older images
# TODO: remove in future
if [ -L /data/nginx/config ]; then
	rm /data/nginx/config /data/nginx/log /data/nginx/www
	mkdir /data/nginx/config /data/nginx/log /data/nginx/www
	mv /etc/nginx/* /data/nginx/config/
	mv /usr/share/nginx/html/* /data/nginx/www/
	mv /var/log/nginx/* /data/nginx/log/
	sed -i 's/\/etc\/nginx/\/data\/nginx\/config/g' `find /data/nginx/config -type f`
	sed -i 's/\/var\/log\/nginx/\/data\/nginx\/log/g' `find /data/nginx/config -type f`
	sed -i 's/\/usr\/share\/nginx\/html/\/data\/nginx\/www/g' `find /data/nginx/config -type f`
	echo -e "daemon off;\n$(cat /data/nginx/config/nginx.conf)" > /data/nginx/config/nginx.conf
fi

if [ ! -e /data/nginx ]; then
	mkdir -p /data/nginx/config /data/nginx/log /data/nginx/www
	cp -a /etc/nginx_dist/* /data/nginx/config/
	if [ -z "$(ls -A /data/nginx/www)" ]; then
		cat <<-HTML > /data/nginx/www/index.html
			<!doctype html>
			Hello, world!<br>
			Docker webserver is alive and ready to serve requests:)
		HTML
	fi
fi

chown git:git /data /data/nginx /data/nginx/log /data/nginx/www
chown -R git:git /data/nginx/config

if [ "$1" = 'nginx' ]; then
	shift
fi

# With CephFS we can't put all all logs into single directory, so let's move them all into local temporary directory
if [ $CEPHFS_MOUNT -eq 1 ]; then
	mkdir -p /tmp/nginx/config /tmp/nginx/log
	chown git:git /tmp/nginx/log
	cp -a /data/nginx/config/* /tmp/nginx/config/
	sed -i 's/\/data\/nginx\/log/\/tmp\/nginx\/log/g' `find /tmp/nginx/config -type f`
	set -- -c /tmp/nginx/config/nginx.conf -p /tmp/nginx/config/ $@
else
	set -- -c /data/nginx/config/nginx.conf -p /data/nginx/config/ $@
fi

if [ -e /data/nginx/before_start.sh ]; then
	bash /data/nginx/before_start.sh
else
	touch /data/nginx/before_start.sh
fi

exec nginx "$@"
