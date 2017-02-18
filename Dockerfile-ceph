FROM ceph/daemon:tag-build-master-kraken-ubuntu-16.04
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

COPY webserver-common /webserver-common/

RUN \

	/webserver-common/apt-get-update.sh && \
	/webserver-common/apt-get-install-common.sh && \
	/webserver-common/apt-get-cleanup.sh

COPY ceph/webserver-entrypoint.sh /

VOLUME /var/lib/ceph

ENV \
	CONSUL_SERVICE=consul \

	CLUSTER=ceph \
	KV_TYPE=consul \
	KV_IP=consul \
	KV_PORT=80 \
	OSD_TYPE=directory \
	CEPHFS_CREATE=1 \
	CEPH_MON_SERVICE=ceph-mon

ENTRYPOINT ["/webserver-entrypoint.sh"]
