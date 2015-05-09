FROM phusion/baseimage:0.9.16
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Enable SSH

RUN rm -f /etc/service/sshd/down && \

# Upgrade system and install git, mc and wget

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y git mc wget && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Create group and user with home directory /data, set empty password to unlock account

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \
	passwd -d git && \

# Rename SSH config directory

	mv /etc/ssh /etc/ssh_dist

# At first we'll check if there any existing config, if not - lets copy default there

CMD (test -f /etc/ssh/sshd_config || cp -a /etc/ssh_dist/* /etc/ssh/) && \

# Now start init as usual

	/sbin/my_init
