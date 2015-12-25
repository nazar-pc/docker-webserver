FROM nginx
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
	apt-get update && \
	apt-get install -y --no-install-recommends ceph-fuse && \
	apt-get purge -y --auto-remove curl ca-certificates && \

	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Change Nginx user

	sed -i 's/user  nginx;/user  git;/g' /etc/nginx/nginx.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /etc/nginx /etc/nginx_dist

COPY ceph-mount.sh /
COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

VOLUME \
	/data \
	/etc/nginx \
	/usr/share/nginx/html \
	/var/log/nginx

ENV \
	CONSUL_SERVICE=consul \

	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
