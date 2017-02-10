#!/bin/bash

config_file=/usr/local/etc/haproxy/haproxy.conf

if [ ! "$SERVICE_NAME" ]; then
	echo 'SERVICE_NAME environmental variable not specified, aborted'
	exit
fi

if [ ! "$SERVICE_PORTS" ]; then
	echo 'SERVICE_PORTS environmental variable not specified, aborted'
	exit
fi

# Watch for DNS changes and keep configuration up to date
while [ true ]; do
	cp $config_file.dist $config_file.new
	for service_port in `echo $SERVICE_PORTS | tr ','  ' '`; do
		echo -e "listen $SERVICE_NAME-$service_port\n\tmode tcp\n\tbind 0.0.0.0:$service_port" >> $config_file.new
		service_nodes=`dig $SERVICE_NAME a +short | sort`
		for service_ip in $service_nodes; do
			echo -e "\tserver $SERVICE_NAME-$service_ip-$service_port $service_ip:$service_port" >> $config_file.new
		done
	done
	if ! cmp --silent $config_file $config_file.new; then
		echo "Configuration updated, reloading"
		cp $config_file.new $config_file
		pid=`pidof haproxy`
		if [ "$pid" ]; then
			haproxy -f $config_file -sf `pidof haproxy` &
		else
			haproxy -f $config_file &
		fi
	fi
	sleep 1
done
