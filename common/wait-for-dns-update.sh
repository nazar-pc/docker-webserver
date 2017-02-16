#!/bin/bash

service_nodes_old=`/webserver-common/list-service-nodes.sh $1`
while [ true ]; do
	sleep 1
	service_nodes_new=`/webserver-common/list-service-nodes.sh $1`
	if [ "$service_nodes_new" != "$service_nodes_old" ]; then
		exit 0
	fi
done
