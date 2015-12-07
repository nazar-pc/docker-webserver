#!/bin/bash

original_resolv_conf=`cat /etc/resolv.conf`
# If consul service specified - we have DNS server there and need to watch for /etc/hosts file changes and keep /etc/resolv.conf up to date
while [ true ]; do
	current_resolv_conf='search service.consul'
	while read service; do
		service_ip=`echo $service | awk '{ print $1 }'`
		current_resolv_conf=`echo -e "$current_resolv_conf\nnameserver $service_ip"`
	done <<< "`grep -P "\w+_${CONSUL_SERVICE}_\d+$" /etc/hosts`"
	echo -e "$current_resolv_conf\n$original_resolv_conf" > /etc/resolv.conf
	inotifywait -e modify -qq /etc/hosts
done &
