FROM mariadb:10
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# Also we'll install MariaDB Gallera server instead of regular in order to be able to build cluster afterwards
# percona-xtrabackup and socat packages contain innobackupex and socat apps that are necessary for Snapshot State Transfer
# We'll need inotify-tools package to watch for files changes
# Upgrade system and install pwgen, which we'll use to generate password

	{ \
		echo mariadb-server-$MARIADB_MAJOR mysql-server/root_password password 'unused'; \
		echo mariadb-server-$MARIADB_MAJOR mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y mariadb-galera-server percona-xtrabackup inotify-tools socat pwgen && \

# Ceph repository for up to date version of ceph-fuse package; Ceph itself is used as cluster filesystem

	CEPH_VERSION=infernalis && \
	apt-get install -y --no-install-recommends curl ca-certificates && \
	curl -sSL 'https://download.ceph.com/keys/release.asc' | apt-key add - && \
	echo "deb http://ceph.com/debian-$CEPH_VERSION/ jessie main" > /etc/apt/sources.list.d/ceph-$CEPH_VERSION.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends ceph-fuse && \
	apt-get purge --auto-remove -y curl ca-certificates && \

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

	sed 's/exec "$@"//g' /docker-entrypoint.sh > /docker-entrypoint-init.sh && \
	chmod +x /docker-entrypoint-init.sh

COPY ceph-mount.sh /
COPY consul-dns.sh /
COPY galera.cnf /etc/mysql_dist/galera.cfg
COPY webserver-entrypoint.sh /

VOLUME \
	/data \
	/etc/mysql \
	/var/lib/mysql \
	/var/log/mysql

ENV \
	CONSUL_SERVICE=consul \

	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0 \

	SERVICE_NAME=mariadb

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["mysqld"]
