#!/bin/bash

/consul-dns.sh &

if [ ! "$SERVICE_NAME" ]; then
	SERVICE_NAME='mysql'
fi

if [ ! -f /etc/mysql/my.cnf ]; then
	mkdir -p /etc/mysql
	chown -R 1000:1000 /etc/mysql
	cp -a /etc/mysql_dist/* /etc/mysql/
fi

if [ ! -f /data/mysql/root_password ]; then
	mkdir -p /data/mysql
	pwgen -s 30 1 > /data/mysql/root_password
fi

MYSQL_ROOT_PASSWORD=`cat /data/mysql/root_password`
echo "MySQL root password (from /data/mysql/root_password): $MYSQL_ROOT_PASSWORD"

# Upgrade MariaDB server to MariaDB Galera server
# TODO remove this block in future, it is here for smooth upgrade from older configurations
if [ ! -f /etc/mysql/galera.cfg ]; then
	echo 'Regular MariaDB server setup detected'
	mysqld --wsrep_on=OFF &
	while [ ! "`ps -A | grep mysqld`" ]; do
		sleep 1
	done
	sleep 3
	echo 'Upgrading to MariaDB Galera server'
	mysql_upgrade --password=$MYSQL_ROOT_PASSWORD
	pkill --signal SIGTERM mysqld
	while [ "`ps -A | grep mysqld`" ]; do
		sleep 1
	done
	echo 'Upgrading to MariaDB Galera server finished'
	sed -i 's/\/var\/lib\/mysql/&_local/g' /etc/mysql/my.cnf
	echo '!include /etc/mysql/galera.cfg' >> /etc/mysql/my.cnf
	cp /etc/mysql_dist/galera.cfg /etc/mysql/galera.cfg
	chown 1000:1000 /etc/mysql/galera.cfg
fi

# Initialize MariaDB using entrypoint from original image without last line
params_before=$@
set -- $@ --wsrep_cluster_address=gcomm:// --wsrep_on=OFF
. /docker-entrypoint-init.sh

# If this is not the only instance of the service - do not use /var/lib/mysql
if [ "`grep -P \"\w+${SERVICE_NAME}_1$\" /etc/hosts`" ]; then
	if [ -L /var/lib/mysql_local ]; then
		echo 'symlink'
		# Change link to local directory to avoid unavoidable conflicts with first node
		rm /var/lib/mysql_local
		mkdir /var/lib/mysql_local
		# Initialize MariaDB using entrypoint from original image without last line
		set -- $@ --wsrep_cluster_address=gcomm:// --wsrep_on=OFF
		. /docker-entrypoint-init.sh
	fi
fi

# Find other existing nodes to connect to
nodes=''
while read service; do
	service_id=`echo $service | awk '{ print $2 }'`
	if [ "$nodes" ]; then
		nodes="$nodes,$service_id"
	else
		nodes="$service_id"
	fi
done <<< "`grep -P "\w+_${SERVICE_NAME}_\d+$" /etc/hosts`"

set -- $params_before  --wsrep_sst_method=xtrabackup-v2 --wsrep_sst_auth=root:$MYSQL_ROOT_PASSWORD --wsrep_cluster_address=gcomm://$nodes

if [ -f /data/mysql/before_start.sh ]; then
	bash /data/mysql/before_start.sh
else
	touch /data/mysql/before_start.sh
fi

exec "$@"
