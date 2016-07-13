FROM phusion/baseimage:0.9.19
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# Enable SSH

	rm -f /etc/service/sshd/down && \

# Upgrade system and install inotify-tools, curl, git, mc, wget and php-cli of course:)

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y inotify-tools curl git mc wget php-cli && \

# Ceph repository for up to date version of ceph-fuse package; Ceph itself is used as cluster filesystem

	CEPH_VERSION=infernalis && \
	curl -sSL 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
	echo "deb http://ceph.com/debian-$CEPH_VERSION/ xenial main" > /etc/apt/sources.list.d/ceph-$CEPH_VERSION.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends ceph-fuse && \

	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Create group and user with home directory /data, set empty password to unlock account

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \
	passwd -d git && \

# Rename SSH config directory

	mv /etc/ssh /etc/ssh_dist && \

# Install Composer

	COMPOSER_VERSION=1.1.3 && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION

COPY ceph-mount.sh /
COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

ENV \
	CONSUL_SERVICE=consul \

	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0 \

	TERM=xterm

VOLUME \
	/data \
	/etc/ssh

ENTRYPOINT ["/webserver-entrypoint.sh"]
