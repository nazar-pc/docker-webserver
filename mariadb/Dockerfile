FROM mariadb
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Change owner of Nginx config directory

RUN chown -R 1000:1000 /etc/mysql && \

# Rename MariaDB config dir

	mv /etc/mysql /etc/mysql_dist

# Reset entrypoint, since we need to run some commands before it

ENTRYPOINT []

# At first we'll check if there any existing config, if not - lets copy default there

CMD (test -f /etc/mysql/my.cnf || cp -a /etc/mysql_dist/* /etc/mysql/) && \

# Now start MariaDB as usual

	`/docker-entrypoint.sh mysqld`
