#!/bin/bash

addgroup -gid 1000 git
useradd -d /data -s /bin/bash -g 1000 -u 1000 git
passwd -d git
