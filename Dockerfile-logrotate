FROM debian:jessie
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

COPY webserver-common /webserver-common/

RUN \

	/webserver-common/apt-get-update.sh && \

	apt-get install -y --no-install-recommends logrotate && \

	/webserver-common/apt-get-cleanup.sh

COPY logrotate/logrotate.conf /etc/logrotate.conf

ENV TERM=xterm

# Run logrotate every hour

CMD watch --no-title --interval 3600 logrotate /etc/logrotate.conf
