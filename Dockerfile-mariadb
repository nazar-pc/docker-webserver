FROM mariadb:10.1
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

COPY webserver-common /webserver-common/

RUN \

	/webserver-common/create-git-user.sh && \

	/webserver-common/apt-get-update.sh && \
	/webserver-common/apt-get-install-common.sh && \
	/webserver-common/apt-get-install-ceph-fuse.sh && \
	/webserver-common/apt-get-cleanup.sh && \

# We'll keep configs in /data/mysql/config on first instance and local directory on others (is set locally in container)

	sed -i 's/\/etc\/mysql/\/data\/mysql\/config/g' /etc/mysql/my.cnf && \

# Append Galera cluster config inclusion to default config

	echo '!include /data/mysql/config/galera.cfg' >> /etc/mysql/my.cnf && \

# We'll keep data in /data/mysql/data on first instance and local directory on others (is set locally in container)

	sed -i 's/\/var\/lib\/mysql/\/data\/mysql\/data/g' /etc/mysql/my.cnf && \

# We'll keep logs in /data/mysql/log on first instance and local directory on others (is set locally in container)

	sed -i 's/\/var\/log\/mysql/\/data\/mysql\/log/g' /etc/mysql/my.cnf && \

# This is to redirect logs to stderr instead of non-running syslog (otherwise error messages will be lost)

	truncate --size=0 /etc/mysql/conf.d/mysqld_safe_syslog.cnf && \

	mv /etc/mysql /etc/mysql_dist && \

# Copy original entrypoint without exec call in order to use it as MariaDB initialization script

	sed 's/exec "$@"//g' /usr/local/bin/docker-entrypoint.sh > /docker-entrypoint-init.sh && \
	chmod +x /docker-entrypoint-init.sh && \

# Restore original ids of mysql user and group, they will replace existing mysql group from the image, which were changed to custom

	userdel mysql && \
	addgroup -gid 999 mysql && \
	useradd -s /bin/bash -g 999 -u 999 mysql

COPY mariadb/galera.cnf /etc/mysql_dist/galera.cfg
COPY mariadb/webserver-entrypoint.sh /

# /tmp will be used for non-master nodes to store data between restarts and image upgrades
VOLUME \
	/data \
	/tmp

ENV \
	CEPH_MON_SERVICE=ceph-mon \
	CEPHFS_MOUNT=0 \

	SERVICE_NAME=mariadb

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["mysqld"]
