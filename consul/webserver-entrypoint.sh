#!/bin/bash
set -e

# Allow to resolve services without `service.consul` suffix and put localhost as one of nameservers
echo -e "search service.consul\nnameserver 127.0.0.1\n`cat /etc/resolv.conf`" > /etc/resolv.conf

if [ ! "$CONSUL_SERVICE" ]; then
	CONSUL_SERVICE='consul'
fi

if [ ! "$SERVICES" ]; then
	echo 'SERVICES environmental variable not specified, aborted'
	exit
fi

# Watch for /etc/hosts file changes and keep configuration up to date
function maintain-configuration {
	update-configuration
	while [ true ]; do
		inotifywait -e modify -qq /etc/hosts
		update-configuration
		pkill -s SIGHUP consul
	done &
}
# Update configuration on /etc/hosts file changes
function update-configuration {
	rm -f /etc/consul.d/haproxy*
	for service in `echo $SERVICES | tr ','  ' '`; do
		service=`echo $service | tr ':'  ' '`
		service_name=`echo $service | awk '{ print $1 }'`
		service_alias=`echo $service | awk '{ print $2 }'`
		if [ ! "$service_alias" ]; then
			service_alias="$service_name"
		fi
		for service in `grep -P "\w+_${service_name}_\d+$" /etc/hosts`; do
			service_id=`echo $service | awk '{ print $2 }'`
			service_ip=`echo $service | awk '{ print $1 }'`
			echo "{\"service\": {\"id\": \"$service_id\", \"name\": \"$service_alias\", \"address\": \"$service_ip\"}}" > /etc/consul.d/haproxy-$service_name.json
		done
	done
}

current_ip=`cat /etc/hosts | awk '{ print $1; exit }'`
cmd="consul agent -server -advertise $current_ip -data-dir /tmp/consul -ui-dir /ui"
# TODO: tricky, but should work, review in future versions of Docker Compose
# $CONSUL_SERVICE contains service name; If service with index 1 not found - very likely this instance has index 1
MASTER_IP=`grep "_${CONSUL_SERVICE}_1" /etc/hosts | awk '{ print $2; exit }'`
if [ "$MASTER_IP" ]; then
	cmd="$cmd -join $MASTER_IP"
	maintain-configuration
else
	if [ "$MIN_SERVERS" ]; then
		cmd="$cmd -bootstrap-expect $MIN_SERVERS"
	else
		cmd="$cmd -bootstrap"
	fi
fi

exec $cmd
