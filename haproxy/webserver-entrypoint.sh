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

# Update configuration on /etc/hosts file changes
function update-configuration {
	cp $config_file.dist $config_file
	for service_port in `echo $SERVICE_PORTS | tr ','  ' '`; do
		echo -e "listen $SERVICE_NAME-$service_port\n\tmode tcp\n\tbind 0.0.0.0:$service_port" >> $config_file
		grep -P "[^_\s]_${SERVICE_NAME}_\d+$" /etc/hosts | while read service; do
			service_id=`echo $service | awk '{ print $2 }'`
			service_ip=`echo $service | awk '{ print $1 }'`
			echo -e "\tserver $service_id $service_ip:$service_port" >> $config_file
		done
	done
}

# Watch for /etc/hosts file changes and keep configuration up to date
while [ true ]; do
	update-configuration
	pid=`pidof haproxy`
	if [ "$pid" ]; then
		haproxy -f $config_file -sf `pidof haproxy` &
	else
		haproxy -f $config_file &
	fi
	inotifywait -e modify -qq /etc/hosts
done
