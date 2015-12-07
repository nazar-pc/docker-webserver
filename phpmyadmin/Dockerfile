FROM nazarpc/phpmyadmin
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# We'll need inotify-tools package to watch for files changes

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

ENV CONSUL_SERVICE=consul

ENTRYPOINT ["/webserver-entrypoint.sh"]
