FROM busybox
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Save volumes into tar file, name of which was specified by BACKUP_FILENAME environment variable

CMD tar -cf "/backup/$BACKUP_FILENAME.tar" \
	/data \
	/etc/mysql \
	/etc/nginx \
	/etc/ssh \
	/usr/local/etc \
	/usr/share/nginx/html \
	/var/lib/mysql \
	/var/log/mysql \
	/var/log/nginx
