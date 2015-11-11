FROM nginx
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

COPY webserver-entrypoint.sh /

# Change Nginx user

RUN sed -i 's/user  nginx;/user  git;/g' /etc/nginx/nginx.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /etc/nginx /etc/nginx_dist

ENTRYPOINT ["/webserver-entrypoint.sh"]
