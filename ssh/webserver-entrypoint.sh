#!/bin/bash
set -e

if [ ! -d /data/.ssh ]; then
	mkdir -p /data/.ssh
	chown 1000:1000 /data
fi

if [ ! -d /data/ssh ]; then
	mkdir -p /data/ssh
	chown 1000:1000 /data
	ln -s /etc/ssh /data/ssh/config
fi

/consul-dns.sh &

if [ ! -f /etc/ssh/sshd_config ]; then
	cp -a /etc/ssh_dist/* /etc/ssh/
fi

if [ -f /data/ssh/before_start.sh ]; then
	bash /data/ssh/before_start.sh
fi

exec /sbin/my_init
