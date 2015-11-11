FROM nazarpc/php:fpm
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

COPY webserver-entrypoint.sh /

# Change PHP-FPM user

RUN sed -i 's/www-data/git/g' /usr/local/etc/php-fpm.conf && \

# Create group and user for PHP-FPM

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /usr/local/etc /usr/local/etc_dist

ENTRYPOINT ["/webserver-entrypoint.sh"]
