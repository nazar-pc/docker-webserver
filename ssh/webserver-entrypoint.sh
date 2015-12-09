#!/bin/bash
set -e

if [ ! -e /data/.ssh ]; then
	mkdir -p /data/.ssh
	chown 1000:1000 /data
fi

if [ ! -e /data/ssh ]; then
	mkdir -p /data/ssh
	chown 1000:1000 /data
	ln -s /etc/ssh /data/ssh/config
fi

/consul-dns.sh &

if [ ! -e /etc/ssh/sshd_config ]; then
	cp -a /etc/ssh_dist/* /etc/ssh/
fi

if [ -e /data/ssh/before_start.sh ]; then
	bash /data/ssh/before_start.sh
fi

exec /sbin/my_init
