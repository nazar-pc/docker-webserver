FROM nazarpc/php:fpm
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# We'll need inotify-tools package to watch for files changes

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \

# Ceph repository for up to date version of ceph-fuse package; Ceph itself is used as cluster filesystem

	CEPH_VERSION=infernalis && \
	apt-get install -y --no-install-recommends curl ca-certificates && \
	curl -sSL 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
	echo "deb http://ceph.com/debian-$CEPH_VERSION/ jessie main" > /etc/apt/sources.list.d/ceph-$CEPH_VERSION.list && \
	apt-get install -y --no-install-recommends ceph-fuse && \
	apt-get purge --auto-remove -y curl ca-certificates && \

	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Change PHP-FPM user

	sed -i 's/www-data/git/g' /usr/local/etc/php-fpm.conf && \

# Create group and user for PHP-FPM

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /usr/local/etc /usr/local/etc_dist

COPY ceph-mount.sh /
COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

VOLUME \
	/data \
	/usr/local/etc

ENV \
	CONSUL_SERVICE=consul \

	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["php-fpm"]
