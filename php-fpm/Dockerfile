FROM nazarpc/php-fpm
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Change PHP-FPM user

RUN sed -i 's/www-data/git/g' /usr/local/etc/php-fpm.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

# Change owner of PHP-FPM config directory

	chown -R git:git /usr/local/etc && \

# Rename PHP-FPM config directory

	mv /usr/local/etc /usr/local/etc_dist

# At first we'll check if there any existing config, if not - lets copy default there

CMD (test -f /usr/local/etc/php-fpm.conf || cp -a /usr/local/etc_dist/* /usr/local/etc/) && \

# Now start PHP-FPM as usual

	php-fpm
