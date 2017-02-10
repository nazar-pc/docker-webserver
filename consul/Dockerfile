FROM debian:jessie
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

RUN \

	CONSUL_VERSION=0.7.4 && \

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends curl ca-certificates unzip dnsutils && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

	curl -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
	curl -o /tmp/consul-ui.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip && \
	unzip -d /bin /tmp/consul.zip && \
	unzip -d /ui /tmp/consul-ui.zip && \
	rm /tmp/consul* && \

	apt-get purge -y --auto-remove curl ca-certificates unzip && \

	mkdir /etc/consul.d_dist && \

# We'll keep files in /var/lib/consul_local which will be symlink to /var/lib/consul on first instance and local directory on others (changed locally in container)

	ln -s /var/lib/consul /var/lib/consul_local && \

# git user as in other images

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git

COPY config.json /etc/consul.d_dist/config.json
COPY webserver-entrypoint.sh /

# /tmp will be used for non-master nodes to store data between restarts and image upgrades
VOLUME \
	/data \
	/etc/consul.d \
	/tmp \
	/var/lib/consul

ENV \
	SERVICE_NAME=consul \
	MIN_SERVERS=1 \
	GOMAXPROCS=2

ENTRYPOINT ["/webserver-entrypoint.sh"]
