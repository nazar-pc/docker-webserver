#!/bin/bash
set -e

if [ ! -f /etc/consul.d/config.json ]; then
	cp -a /etc/consul.d_dist/* /etc/consul.d/
	chown -R 1000:1000 /etc/consul.d
fi

if [ ! -d /data/consul ]; then
	mkdir -p /data/consul
	chown 1000:1000 /data
	ln -s /etc/consul.d /data/consul/config
	ln -s /var/lib/consul /data/consul/data
	chown -R 1000:1000 /data/consul
fi

# Configure recursive DNS resolving
recursors=''
while read nameserver; do
	nameserver_ip=`echo $nameserver | awk '{ print $2 }'`
	if [ "$recursors" ]; then
		recursors="$recursors,\"$nameserver_ip\""
	else
		recursors="\"$nameserver_ip\""
	fi
done <<< "`grep -P "^nameserver" /etc/resolv.conf`"
echo "{\"recursors\": [$recursors]}" > /etc/consul.d/recursors.json

# Allow to resolve services without `service.consul` suffix and put localhost as first nameserver
echo -e "search service.consul\nnameserver 127.0.0.1\n`cat /etc/resolv.conf`" > /etc/resolv.conf

if [ ! "$CONSUL_SERVICE" ]; then
	CONSUL_SERVICE='consul'
fi

if [ ! "$SERVICES" ]; then
	echo 'SERVICES environmental variable not specified, aborted'
	exit
fi

if [ ! "$MIN_SERVERS" ]; then
	MIN_SERVERS=1
fi

# Watch for /etc/hosts file changes and keep configuration up to date
function maintain-configuration {
	update-configuration
	while [ true ]; do
		inotifywait -e modify -qq /etc/hosts
		update-configuration
		pkill --signal SIGHUP consul
	done &
}
# Update configuration on /etc/hosts file changes
function update-configuration {
	rm -f /etc/consul.d/service-*
	for service in `echo $SERVICES | tr ','  ' '`; do
		service=`echo $service | tr ':'  ' '`
		service_name=`echo $service | awk '{ print $1 }'`
		service_alias=`echo $service | awk '{ print $2 }'`
		if [ ! "$service_alias" ]; then
			service_alias="$service_name"
		fi
		while read service; do
			if [ "$service" ]; then
				service_id=`echo $service | awk '{ print $2 }'`
				service_ip=`echo $service | awk '{ print $1 }'`
				echo "{\"service\": {\"id\": \"$service_id-$service_alias\", \"name\": \"$service_alias\", \"address\": \"$service_ip\"}}" > /etc/consul.d/service-$service_name-$service_alias.json
			fi
		done <<< "`grep -P "\w+_${service_name}_\d+$" /etc/hosts`"
	done
}

current_ip=`cat /etc/hosts | awk '{ print $1; exit }'`
cmd="consul agent -server -advertise $current_ip -config-dir /etc/consul.d $@"
# TODO: tricky, but should work, review in future versions of Docker Compose
# $CONSUL_SERVICE contains service name; If service with index 1 not found - very likely this instance has index 1
MASTER_ADDRESS=`grep -P "_${CONSUL_SERVICE}_1$" /etc/hosts | awk '{ print $2; exit }'`
if [ "$MASTER_ADDRESS" ]; then
	if [ -L /var/lib/consul_local ]; then
		# Change link to local directory to avoid unavoidable conflicts with first node
		rm /var/lib/consul_local
		mkdir /var/lib/consul_local
	fi
	cmd="$cmd -retry-join $MASTER_ADDRESS"
else
	cmd="$cmd -bootstrap-expect $MIN_SERVERS"
	maintain-configuration
fi

exec $cmd
