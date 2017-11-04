#!/bin/bash

# Ceph repository for up to date version of ceph-fuse package; Ceph-fuse itself is used as cluster filesystem CephFS

# TODO: Do not install Ceph until http://tracker.ceph.com/issues/21585 is resolved
#CEPH_VERSION=kraken
#curl -sSL 'https://download.ceph.com/keys/release.asc' | apt-key add -
#echo "deb http://download.ceph.com/debian-$CEPH_VERSION/ $(cat /etc/apt/sources.list | awk '{ print $3; exit }') main" > /etc/apt/sources.list.d/ceph-$CEPH_VERSION.list
#apt-get update
#apt-get install -y --no-install-recommends ceph-fuse
