FROM nginx
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# We'll need inotify-tools package to watch for files changes

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends inotify-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Change Nginx user

	sed -i 's/user  nginx;/user  git;/g' /etc/nginx/nginx.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /etc/nginx /etc/nginx_dist

COPY consul-dns.sh /
COPY webserver-entrypoint.sh /

VOLUME \
	/data \
	/etc/nginx \
	/usr/share/nginx/html \
	/var/log/nginx

ENV CONSUL_SERVICE=consul

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
