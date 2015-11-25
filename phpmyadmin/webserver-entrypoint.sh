#!/bin/bash
set -e

/consul-dns.sh &

exec /home/entrypoint.sh
