#!/bin/bash

/webserver-common/ceph-mount.sh /data

# Automatic upgrade from older images
# TODO: remove in future
if [ -L /data/mysql/config ]; then
	rm /data/mysql/config /data/mysql/data /data/mysql/log
	mkdir /data/mysql/config /data/mysql/data /data/mysql/log
	mv /etc/mysql/* /data/mysql/config/
	mv /var/lib/mysql/* /data/mysql/data/
	mv /var/log/mysql/* /data/mysql/log/
	sed -i 's/\/etc\/mysql/\/data\/mysql\/config/g' /data/mysql/config/my.cnf
	sed -i 's/\/var\/lib\/mysql_local/\/data\/mysql\/data/g' /data/mysql/config/my.cnf
	sed -i 's/\/var\/log\/mysql/\/data\/mysql\/log/g' /etc/mysql/my.cnf
fi

if [ ! -e /data/mysql ]; then
	mkdir -p /data/mysql/config /data/mysql/data /data/mysql/log
	cp -a /etc/mysql_dist/* /data/mysql/config/
fi

chown git:git /data /data/mysql
chown -R git:git /data/mysql/config
chown mysql:mysql /data/mysql/data /data/mysql/log
chmod 770 /data/mysql/data

if [ ! -e /data/mysql/root_password ]; then
	pwgen -s 30 1 > /data/mysql/root_password
fi

export MYSQL_ROOT_PASSWORD=`cat /data/mysql/root_password`
echo "MySQL root password (from /data/mysql/root_password): $MYSQL_ROOT_PASSWORD"

if [ "$1" = 'mysqld' ]; then
	shift
fi
set -- --wsrep_sst_method=xtrabackup-v2 --wsrep_sst_auth=root:$MYSQL_ROOT_PASSWORD $@

# If this is not the master node of the service (first instance that have started) - do not use /data/mysql/data and /data/mysql/log and try to connect to the master node
/webserver-common/determine-service-master-node.sh /data/mysql/master_node_ip $SERVICE_NAME
master_node=`cat /data/mysql/master_node_ip`
if [[ "$master_node" &&  (! "`cat /etc/hosts | grep $master_node`") ]]; then
	echo "Starting as regular node (no synchronization to permanent storage)"
	set -- --defaults-file=/tmp/mysql/config/my.cnf $@

	if [ ! -e /tmp/mysql ]; then
		mkdir -p /tmp/mysql/config /tmp/mysql/data /tmp/mysql/log
		chown mysql:mysql /tmp/mysql/data /tmp/mysql/log
		cp /data/mysql/config/my.cnf /tmp/mysql/config/my.cnf
		sed -i 's/\/data\/mysql\/data/\/tmp\/mysql\/data/g' /tmp/mysql/config/my.cnf
		sed -i 's/\/data\/mysql\/log/\/tmp\/mysql\/log/g' /tmp/mysql/config/my.cnf
		# Initialize MariaDB using entrypoint from original image without last line
		gosu mysql /docker-entrypoint-init.sh "$@ --bind_address=127.0.0.1 --wsrep_cluster_address=gcomm:// --wsrep_on=OFF"
	fi
	if ! mysqladmin --host=$master_node --user=root --password=$MYSQL_ROOT_PASSWORD ping; then
		echo 'Master node is not ready, exiting'
		sleep 1
	fi
	set -- $@ --wsrep_cluster_address=gcomm://$master_node
else
	echo "Starting as master node (with synchronization to permanent storage)"
	hostname > /data/mysql/master_node_hostname
	set -- --defaults-file=/data/mysql/config/my.cnf $@

	# Initialize MariaDB using entrypoint from original image without last line
	gosu mysql /docker-entrypoint-init.sh "$@ --bind_address=127.0.0.1 --wsrep_cluster_address=gcomm:// --wsrep_on=OFF"

	# Find other existing node to connect to
	existing_nodes=''
	for node_ip in `/webserver-common/list-service-nodes.sh $SERVICE_NAME`; do
		if [[ "$node_ip" && "$node_ip" != "$master_node" ]]; then
			# Check if node is ready
			if mysqladmin --host=$node_ip --user=root --password=$MYSQL_ROOT_PASSWORD ping; then
				existing_nodes="$existing_nodes,$node_ip"
				break
			fi
		fi
	done
	# When first node fails to connect to any other node from the cluster, then we need to force its start
	# TODO: Ideally instances should communicate about who's version of history is more recent and then start cluster from that node,
	# but for now we assume master not to be always up to date
	if [ ! "$existing_nodes" ]; then
		echo "No existing alive nodes found in cluster, forcing start in master node"
		if [ -e /data/mysql/data/grastate.dat ]; then
			sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /data/mysql/data/grastate.dat
		fi
	fi
	set -- $@ --wsrep_cluster_address=gcomm://${existing_nodes:1}
fi

if [ -e /data/mysql/before_start.sh ]; then
	bash /data/mysql/before_start.sh
else
	touch /data/mysql/before_start.sh
fi

exec gosu mysql mysqld "$@"
