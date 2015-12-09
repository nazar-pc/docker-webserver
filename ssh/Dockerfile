FROM phusion/baseimage:0.9.18
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# Enable SSH

	rm -f /etc/service/sshd/down && \

# Upgrade system and install curl, git, mc and wget

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y curl git mc wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Create group and user with home directory /data, set empty password to unlock account

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \
	passwd -d git && \

# Rename SSH config directory

	mv /etc/ssh /etc/ssh_dist

COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

ENV \
	CONSUL_SERVICE=consul \

	TERM=xterm

VOLUME \
	/data \
	/etc/ssh

ENTRYPOINT ["/webserver-entrypoint.sh"]
