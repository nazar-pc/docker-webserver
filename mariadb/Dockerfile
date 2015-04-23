FROM mariadb
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

# Upgrade system and install pwgen, which we'll use to generate password

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y pwgen && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

# Change owner of MariaDB config directory

	chown -R 1000:1000 /etc/mysql && \

# Rename MariaDB config dir

	mv /etc/mysql /etc/mysql_dist

# Reset entrypoint, since we need to run some commands before it

ENTRYPOINT []

# At first we'll check if there any existing config, if not - lets copy default there

CMD (test -f /etc/mysql/my.cnf || cp -a /etc/mysql_dist/* /etc/mysql/) && \

# Check if there is no environment stored DB root password - generate new one and store as /data/mysql/root_password

	(test -f /data/mysql/root_password || pwgen -s 30 1 > /data/mysql/root_password) && \

# Load DB root password into environment variable MYSQL_ROOT_PASSWORD and echo it, so that it can be found in `docker logs`

	export MYSQL_ROOT_PASSWORD=`cat /data/mysql/root_password` && \
	echo "MySQL root password: ${MYSQL_ROOT_PASSWORD}" && \

# Then check if there any before_start.sh file and if so - run it

	(test ! -f /data/mysql/before_start.sh || sh /data/mysql/before_start.sh) && \

# Now start MariaDB as usual

	`/docker-entrypoint.sh mysqld`
