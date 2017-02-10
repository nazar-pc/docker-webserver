#!/bin/bash
set -e

/ceph-mount.sh \
	/data \
	/etc/ssh

if [ ! -e /data/.ssh ]; then
	mkdir -p /data/.ssh
fi

if [ ! -e /data/ssh ]; then
	mkdir -p /data/ssh
	ln -s /etc/ssh /data/ssh/config
fi

chown git:git /data

if [ ! -e /etc/ssh/sshd_config ]; then
	cp -a /etc/ssh_dist/* /etc/ssh/
fi

if [ -e /data/ssh/before_start.sh ]; then
	bash /data/ssh/before_start.sh
fi

exec /sbin/my_init
