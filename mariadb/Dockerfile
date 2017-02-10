FROM mariadb:10.1
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

RUN \

# We'll need dnsutils package for DNS lookups

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y dnsutils && \

# Ceph repository for up to date version of ceph-fuse package; Ceph itself is used as cluster filesystem

	CEPH_VERSION=kraken && \
	apt-get install -y --no-install-recommends curl ca-certificates && \
	curl -sSL 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
	apt-get purge -y --auto-remove curl && \
	echo "deb http://download.ceph.com/debian-$CEPH_VERSION/ jessie main" > /etc/apt/sources.list.d/ceph-$CEPH_VERSION.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends ceph-fuse && \

	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Append Galera cluster config inclusion to default config

	echo '!include /etc/mysql/galera.cfg' >> /etc/mysql/my.cnf && \

# We'll keep files in /var/lib/mysql_local which will be symlink to /var/lib/mysql on first instance and local directory on others (changed locally in container)

	sed -i 's/\/var\/lib\/mysql/&_local/g' /etc/mysql/my.cnf && \
	ln -s /var/lib/mysql /var/lib/mysql_local && \

# This is to redirect logs to stderr instead of non-running syslog (otherwise error messages will be lost)

	truncate --size=0 /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \

	mv /etc/mysql /etc/mysql_dist && \

# Copy original entrypoint without exec call in order to use it as MariaDB initialization script

	sed 's/exec "$@"//g' /usr/local/bin/docker-entrypoint.sh > /docker-entrypoint-init.sh && \
	chmod +x /docker-entrypoint-init.sh && \

# Restore original ids of mysql user and group, they will replace existing mysql group from the image, which were changed to custom

	userdel mysql && \
	addgroup -gid 999 mysql && \
	useradd -d /data -s /bin/bash -g 999 -u 999 mysql && \

# git user as in other images

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git

COPY ceph-mount.sh /
COPY galera.cnf /etc/mysql_dist/galera.cfg
COPY webserver-entrypoint.sh /

# /tmp will be used for non-master nodes to store data between restarts and image upgrades
VOLUME \
	/data \
	/etc/mysql \
	/tmp \
	/var/lib/mysql \
	/var/log/mysql

ENV \
	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0 \

	SERVICE_NAME=mariadb

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["mysqld"]
