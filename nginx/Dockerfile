FROM nginx
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Change Nginx user

RUN sed -i 's/user  nginx;/user  git;/g' /etc/nginx/nginx.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

	mv /etc/nginx /etc/nginx_dist

COPY webserver-entrypoint.sh /

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
