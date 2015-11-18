FROM haproxy:1
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


COPY haproxy.conf /usr/local/etc/haproxy/haproxy.conf.dist
COPY webserver-entrypoint.sh /

ENTRYPOINT ["/webserver-entrypoint.sh"]
