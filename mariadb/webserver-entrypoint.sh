#!/bin/bash

if [ ! -f /etc/mysql/my.cnf ]; then
	cp -a /etc/mysql_dist/* /etc/mysql/
	chown -R 1000:1000 /etc/mysql
fi

if [ ! -d /data/mysql ]; then
	mkdir -p /data/mysql
	chown 1000:1000 /data
	ln -s /etc/mysql /data/mysql/config
	ln -s /var/log/mysql /data/mysql/log
	ln -s /var/lib/mysql /data/mysql/data
	chown -R 1000:1000 /data/mysql
fi

if [ ! "$SERVICE_NAME" ]; then
	SERVICE_NAME='mariadb'
fi

if [ ! -f /data/mysql/root_password ]; then
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
params_before="$@ --wsrep_sst_method=xtrabackup-v2 --wsrep_sst_auth=root:$MYSQL_ROOT_PASSWORD"
set -- $@ --bind_address=127.0.0.1 --wsrep_cluster_address=gcomm:// --wsrep_on=OFF
. /docker-entrypoint-init.sh

# If this is not the only instance of the service - do not use /var/lib/mysql
first_node="`grep -P \"\w+${SERVICE_NAME}_1$\" /etc/hosts | awk '{ print $2 }'`"
if [ "$first_node" ]; then
	if [ -L /var/lib/mysql_local ]; then
		# Change link to local directory to avoid unavoidable conflicts with first node
		rm /var/lib/mysql_local
		mkdir /var/lib/mysql_local
		# Initialize MariaDB using entrypoint from original image without last line
		set -- $@ --bind_address=127.0.0.1 --wsrep_cluster_address=gcomm:// --wsrep_on=OFF
		. /docker-entrypoint-init.sh
	fi
	while [[ ! `mysqladmin --host=$first_node --user=root --password=$MYSQL_ROOT_PASSWORD ping` ]]; do
		echo 'Waiting for the first node to be ready'
		sleep 1
	done
	params_before="$params_before --wsrep_cluster_address=gcomm://$first_node"
else
	# Find other existing node to connect to
	target_node=''
	while read service; do
		service_ip=`echo $service | awk '{ print $1 }'`
		# Check if node is ready
		if [[ `mysqladmin --host=$service_ip --user=root --password=$MYSQL_ROOT_PASSWORD ping` ]]; then
			target_node=$service_ip
			break
		fi
	done <<< "`grep -P "\w+_${SERVICE_NAME}_\d+$" /etc/hosts`"
	params_before="$params_before --wsrep_cluster_address=gcomm://$target_node"
fi

set -- $params_before

if [ -f /data/mysql/before_start.sh ]; then
	bash /data/mysql/before_start.sh
else
	touch /data/mysql/before_start.sh
fi

exec "$@"
