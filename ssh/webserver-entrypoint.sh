#!/bin/bash
set -e

/consul-dns.sh &

/ceph-mount.sh \
	/data \
	/etc/ssh

mkdir -p /data/{ssh,.ssh}
chown 1000:1000 /data

if [ ! -e /etc/ssh/config ]; then
	ln -s /etc/ssh /data/ssh/config
fi

if [ ! -e /etc/ssh/sshd_config ]; then
	cp -a /etc/ssh_dist/* /etc/ssh/
fi

if [ -e /data/ssh/before_start.sh ]; then
	bash /data/ssh/before_start.sh
fi

exec /sbin/my_init
