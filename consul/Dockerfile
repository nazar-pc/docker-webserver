FROM debian:jessie
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN CONSUL_VERSION=0.5.2 && \

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends curl ca-certificates unzip inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

	curl -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
	curl -o /tmp/consul-ui.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip && \
	unzip -d /bin /tmp/consul.zip && \
	unzip -d / /tmp/consul-ui.zip && \
	mv /dist /ui && \
	rm /tmp/consul* && \

	apt-get purge --auto-remove -y curl ca-certificates unzip && \

	mkdir /etc/consul.d

COPY config.json /etc/consul.d/config.json
COPY webserver-entrypoint.sh /

ENV GOMAXPROCS 2

ENTRYPOINT ["/webserver-entrypoint.sh"]
