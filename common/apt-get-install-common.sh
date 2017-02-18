#!/bin/bash

# We'll need dnsutils package for DNS lookups, curl is used in many images for downloading stuff

apt-get install -y --no-install-recommends curl ca-certificates dnsutils
