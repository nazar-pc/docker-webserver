FROM nazarpc/php:fpm
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

COPY webserver-common /webserver-common/

RUN \

	/webserver-common/create-git-user.sh && \

	/webserver-common/apt-get-update.sh && \
	/webserver-common/apt-get-install-common.sh && \
	/webserver-common/apt-get-install-ceph-fuse.sh && \
	/webserver-common/apt-get-cleanup.sh && \

# Change PHP-FPM user

	sed -i 's/www-data/git/g' /usr/local/etc/php-fpm.d/www.conf && \

# We'll keep configs in /data/php/config

	sed -i 's/etc\/php-fpm.d/php-fpm.d/g' /usr/local/etc/php-fpm.conf && \

	mv /usr/local/etc /usr/local/etc_dist

COPY php-fpm/webserver-entrypoint.sh /

VOLUME \
	/data

# We're changing directory for configs, so this variables will help PHP to find its modules

ENV \
	PHP_INI_DIR=/data/php/config \
	PHP_INI_SCAN_DIR=/data/php/config/php/conf.d

ENV \
	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["php-fpm"]
