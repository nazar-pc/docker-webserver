#!/bin/bash

cat /etc/hosts | grep `hostname` | awk '{ print $1; exit }'
