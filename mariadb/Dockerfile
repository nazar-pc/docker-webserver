FROM mariadb
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

COPY webserver-entrypoint.sh /

# Upgrade system and install pwgen, which we'll use to generate password

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y pwgen && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \

	mv /etc/mysql /etc/mysql_dist && \

	cat /docker-entrypoint.sh >> /webserver-entrypoint.sh

ENTRYPOINT ["/webserver-entrypoint.sh"]

CMD ["mysqld"]
