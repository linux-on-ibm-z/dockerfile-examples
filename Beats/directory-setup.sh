#!/bin/bash

set -euo pipefail

# Set up directory for Beats

# Reference for non-s390x directory layout:
# https://www.elastic.co/guide/en/beats/packetbeat/current/directory-layout.html#_docker

# All beat binaries and configuration files are located in /usr/share/beats
# for s390x docker image

beats="auditbeat filebeat heartbeat journalbeat metricbeat packetbeat"
BEATSHOME=/usr/share/beats
mkdir -p $BEATSHOME

for beat in $beats
do
  cp $GOPATH/src/github.com/elastic/beats/$beat/$beat $BEATSHOME
  cp $GOPATH/src/github.com/elastic/beats/$beat/$beat*.yml $BEATSHOME
done

mkdir -p $BEATSHOME/data $BEATSHOME/logs
chown -R root:root $BEATSHOME
find $BEATSHOME -type d -exec chmod 0755 {} \;
find $BEATSHOME -type f -exec chmod 0644 {} \;
chmod 0775 $BEATSHOME/data $BEATSHOME/logs

for beat in $beats
do
    chmod 0755 $BEATSHOME/$beat
done
