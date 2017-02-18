#!/bin/bash

if [[ ! "$@" || $CEPHFS_MOUNT -ne 1 ]]; then
	exit
fi

echo "Have some mount points to mount"

mkdir -p /ceph
mkdir -p /etc/ceph
echo -e "[global]\nauth client required = none" > /etc/ceph/ceph.conf
echo "Mounting /ceph..."
while ! `ceph-fuse -m $CEPH_MON_SERVICE /ceph && mount | grep -q /ceph`; do
	echo "Mounting failed, trying again in 1 second"
	sleep 1
done

for mount_point in $@; do
	echo "Mounting $mount_point..."
	mkdir -p /ceph$mount_point
	mount --bind /ceph$mount_point $mount_point
done
