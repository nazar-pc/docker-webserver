#!/bin/bash

if [ ! -f /etc/mysql/my.cnf ]; then
	mkdir -p /etc/mysql
	chown -R 1000:1000 /etc/mysql
	cp -a /etc/mysql_dist/* /etc/mysql/
fi

if [ ! -f /data/mysql/root_password ]; then
	mkdir -p /data/mysql
	pwgen -s 30 1 > /data/mysql/root_password
fi

MYSQL_ROOT_PASSWORD=`cat /data/mysql/root_password`
echo "MySQL root password: ${MYSQL_ROOT_PASSWORD}"

if [ -f /data/mysql/before_start.sh ]; then
	bash /data/mysql/before_start.sh
fi

# Contents of entrypoint from original image below
