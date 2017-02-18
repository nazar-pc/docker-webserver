#!/bin/bash

own_ip=`/webserver-common/get-own-ip.sh`
cmd="consul agent -server -advertise $own_ip -config-dir /etc/consul.d -bootstrap-expect $MIN_SERVERS $@"

# Try to join other nodes in cluster
for node_ip in `/webserver-common/list-service-nodes.sh $SERVICE_NAME`; do
	if [[ "$node_ip" && "$node_ip" != "$own_ip" ]]; then
		cmd="$cmd -retry-join $node_ip"
	fi
done

exec $cmd
