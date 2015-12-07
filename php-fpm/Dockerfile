FROM nazarpc/php:fpm
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# We'll need inotify-tools package to watch for files changes

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Change PHP-FPM user

	sed -i 's/www-data/git/g' /usr/local/etc/php-fpm.conf && \

# Create group and user for PHP-FPM

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /usr/local/etc /usr/local/etc_dist

COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

VOLUME \
	/data \
	/usr/local/etc

ENV CONSUL_SERVICE=consul

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["php-fpm"]
