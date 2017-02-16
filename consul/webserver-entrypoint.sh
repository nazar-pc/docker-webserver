#!/bin/bash

if [ ! -e /etc/consul.d/config.json ]; then
	cp -a /etc/consul.d_dist/* /etc/consul.d/
fi

if [ ! -e /data/consul ]; then
	mkdir -p /data/consul
	ln -s /etc/consul.d /data/consul/config
	ln -s /var/lib/consul /data/consul/data
fi

chown git:git /data
chown -R git:git /data/consul /etc/consul.d

own_ip=`/webserver-common/get-own-ip.sh`
cmd="consul agent -server -advertise $own_ip -config-dir /etc/consul.d $@"
# If this is not the master node of the service (first instance that have started) - do not use /var/lib/consul and try to connect to the master node
/webserver-common/determine-service-master-node.sh /data/consul/master_node_ip $SERVICE_NAME
master_node=`cat /data/consul/master_node_ip`
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
for node_ip in `/webserver-common/list-service-nodes.sh $SERVICE_NAME`; do
	if [[ "$node_ip" && "$node_ip" != "$own_ip" ]]; then
		cmd="$cmd -retry-join $node_ip"
	fi
done

set -e
exec $cmd
