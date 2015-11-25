FROM nazarpc/phpmyadmin
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# We'll need inotify-tools package to watch for files changes

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

ENTRYPOINT ["/webserver-entrypoint.sh"]
