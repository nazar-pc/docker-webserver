#!/bin/bash
set -e

/consul-dns.sh &

if [ ! -f /etc/ssh/sshd_config ]; then
	mkdir -p /etc/ssh/
	cp -a /etc/ssh_dist/* /etc/ssh/
fi

if [ -f /data/ssh/before_start.sh ]; then
	bash /data/ssh/before_start.sh
fi

if [ "$1" ]; then
	exec /sbin/my_init -- $@
else
	exec /sbin/my_init
fi
