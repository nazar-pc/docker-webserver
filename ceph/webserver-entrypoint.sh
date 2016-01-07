#!/bin/bash
set -e

/consul-dns.sh &

if [ "$CONSUL_SERVICE" ]; then
	export KV_IP=$CONSUL_SERVICE
fi

if [ ! "$MON_IP" ]; then
	if [ "$1" == 'mon' ]; then
		# If we are running monitor - use host IP
		export MON_IP=`cat /etc/hosts | awk '{ print $1; exit }'`
	else
		# Otherwise use host name
		export MON_IP=$CEPH_MON_SERVICE
	fi
fi

if [ ! "$CEPH_PUBLIC_NETWORK" ]; then
	export CEPH_PUBLIC_NETWORK=`ip addr | grep $MON_IP | awk '{ print $2 }'`
fi

exec /entrypoint.sh $@
