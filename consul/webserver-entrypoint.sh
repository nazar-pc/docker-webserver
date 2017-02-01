#!/bin/bash

if [ ! -e /etc/consul.d/config.json ]; then
	cp -a /etc/consul.d_dist/* /etc/consul.d/
	chown -R 1000:1000 /etc/consul.d
fi

if [ ! -e /data/consul ]; then
	mkdir -p /data/consul
	chown 1000:1000 /data
	ln -s /etc/consul.d /data/consul/config
	ln -s /var/lib/consul /data/consul/data
	chown -R 1000:1000 /data/consul
fi

hostname=`hostname`
current_ip=`cat /etc/hosts | grep $hostname | awk '{ print $1; exit }'`
cmd="consul agent -server -advertise $current_ip -config-dir /etc/consul.d $@"
# If this is not the master node of the service (first instance that have started) - do not use /var/lib/consul and try to connect to the master node
service_nodes=`dig $SERVICE_NAME a +short | sort`
master_node=`cat /data/consul/master_node_ip`
if [ ! "`echo $service_nodes | grep $master_node`" ]; then
	first_node=`echo $service_nodes | awk '{ print $1; exit }'`
	echo "Master node $master_node not reachable, changing to the first node $first_node"
	master_node=$first_node
	echo $master_node > /data/consul/master_node_ip
fi
if [ ! "`cat /etc/hosts | grep $master_node`" ]; then
	echo "Starting as regular node (no synchronization to permanent storage)"
	if [ -L /var/lib/consul_local ]; then
		# Change link to local directory to avoid unavoidable conflicts with master node
		rm /var/lib/consul_local
		mkdir /tmp/consul_local
		ln -s /tmp/consul_local /var/lib/consul_local
	fi
else
	echo "Starting as master node (with synchronization to permanent storage)"
	hostname > /data/consul/master_node_hostname
	cmd="$cmd -bootstrap-expect $MIN_SERVERS"
fi

# Try to join other nodes in cluster
for node_ip in $service_nodes; do
	if [[ "$node_ip" && "$node_ip" != "$current_ip" ]]; then
		cmd="$cmd -retry-join $node_ip"
	fi
done

set -e
exec $cmd
