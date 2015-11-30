FROM debian:jessie
MAINTAINER Nazar Mokrynskyi <nazar@mokrynskyi.com>

RUN \

# Upgrade system and install logrotate, which we'll use to rotate logs

	apt-get update && \
	apt-get upgrade -y && \
	apt-get install --no-install-recommends -y logrotate && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY logrotate.conf /etc/logrotate.conf

ENV TERM=xterm

# Run logrotate every hour

CMD watch --no-title --interval 3600 logrotate /etc/logrotate.conf
