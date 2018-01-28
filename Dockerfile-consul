FROM debian:jessie
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

COPY webserver-common /webserver-common/

RUN \

	/webserver-common/apt-get-update.sh && \
	/webserver-common/apt-get-install-common.sh && \

	CONSUL_VERSION=1.0.3 && \

	apt-get install -y --no-install-recommends unzip && \

	curl -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
	unzip -d /bin /tmp/consul.zip && \
	rm /tmp/consul.zip && \

	apt-get purge -y unzip && \

	/webserver-common/apt-get-cleanup.sh && \

	mkdir /etc/consul.d

COPY consul/config.json /etc/consul.d/config.json
COPY consul/webserver-entrypoint.sh /

# /tmp will be used for non-master nodes to store data between restarts and image upgrades
VOLUME \
	/var/lib/consul

ENV \
	SERVICE_NAME=consul \
	MIN_SERVERS=3 \
	GOMAXPROCS=2

ENTRYPOINT ["/webserver-entrypoint.sh"]
