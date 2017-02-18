#!/bin/bash

# First argument is file where master node IP will be stored
master_node_ip_file=$1
# Second argument is the service name
service_nodes=`/webserver-common/list-service-nodes.sh $2`
first_node=`echo $service_nodes | awk '{ print $1; exit }'`
if [ ! -e $master_node_ip_file ]; then
	echo "No master node found, changing to the first node $first_node"
	master_node=$first_node
	echo $master_node > $master_node_ip_file
else
	master_node=`cat $master_node_ip_file`
	if [ ! "`echo $service_nodes | grep $master_node`" ]; then
		echo "Master node $master_node not reachable, changing to the first node $first_node"
		master_node=$first_node
		echo $master_node > $master_node_ip_file
	fi
fi
echo "Master node IP: $master_node"
