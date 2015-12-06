FROM busybox
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# Create main directories for Consul, MySQL (MariaDB), Nginx, PHP-FPM and SSH

	mkdir /etc/consul.d && \
	mkdir /etc/mysql && \
	mkdir -p /var/lib/mysql && \
	mkdir -p /var/log/mysql && \

	mkdir -p /usr/share/nginx/html && \
	mkdir /var/log/nginx && \

	mkdir -p /usr/local/etc && \

	mkdir /etc/ssh && \

# Setting directories owners for MySQL (MariaDB) and Nginx (like they are in corresponding official images)

	chown 999:999 /var/lib/mysql && \
	chmod 770 /var/lib/mysql && \
	chown 999:999 /var/log/mysql && \

	chown 1000:1000 /usr/share/nginx/html && \
	chown 1000:1000 /var/log/nginx && \

# Create /data directory and inside symlinks for all other directories

	mkdir /data && \

# Set owner of new directories

	chown 1000:1000 /data

VOLUME \
	/data \
	/etc/consul.d \
	/etc/mysql \
	/etc/nginx \
	/etc/ssh \
	/usr/local/etc \
	/usr/share/nginx/html \
	/var/lib/consul \
	/var/lib/mysql \
	/var/log/mysql \
	/var/log/nginx
