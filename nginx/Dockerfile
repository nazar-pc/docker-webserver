FROM nginx
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Change Nginx user

RUN sed -i 's/user  nginx;/user  git;/g' /etc/nginx/nginx.conf && \

# Create group and user for Nginx

	addgroup -gid 1000 git && \
	useradd -d /data -s /bin/bash -g 1000 -u 1000 git && \

# Change owner of Nginx config directory

	chown -R git:git /etc/nginx && \

# Rename Nginx config directory

	mv /etc/nginx /etc/nginx_dist

# At first we'll check if there any existing config, if not - lets copy default there

CMD (test -f /etc/nginx/nginx.conf || cp -a /etc/nginx_dist/* /etc/nginx/) && \

# Now start Nginx as usual

	nginx -g "daemon off;"
