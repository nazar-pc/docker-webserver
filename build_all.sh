#!/bin/bash

docker build -f Dockerfile-backup		-t nazarpc/webserver:backup		.
docker build -f Dockerfile-ceph			-t nazarpc/webserver:ceph		.
docker build -f Dockerfile-consul		-t nazarpc/webserver:consul		.
docker build -f Dockerfile-data			-t nazarpc/webserver:data		.
docker build -f Dockerfile-haproxy		-t nazarpc/webserver:haproxy	.
docker build -f Dockerfile-logrotate	-t nazarpc/webserver:logrotate	.
docker build -f Dockerfile-mariadb		-t nazarpc/webserver:mariadb	.
docker build -f Dockerfile-nginx		-t nazarpc/webserver:nginx		.
docker build -f Dockerfile-php-fpm		-t nazarpc/webserver:php-fpm	.
docker build -f Dockerfile-phpmyadmin	-t nazarpc/webserver:phpmyadmin	.
docker build -f Dockerfile-restore		-t nazarpc/webserver:restore	.
docker build -f Dockerfile-ssh			-t nazarpc/webserver:ssh		.
