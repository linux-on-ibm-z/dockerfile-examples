# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Beats 7.4.1 #############################
# Beats is the platform for single-purpose data shippers
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create a container of Beats image run the below command:
# docker run --name <container_name> -it  <image_name> /bin/bash
#
# The following modules are present in beats: heartbeat ,filebeat ,metricbeat , packetbeat, libbeat, auditbeat journalbeat
# docker run --name <container_name> -e BEATSNAME=<beat_name> -d <image_name>
#
# To run a particular module like heartbeat run the following command:
# docker run --name <container_name> -e BEATSNAME=heartbeat -d <image_name>
#
# Note : To run auditbeat use options : --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host to docker run
# docker run --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host --name <container_name> -e BEATSNAME=auditbeat -d <image_name>
###########################################################################################################

# Base image
FROM s390x/ubuntu:18.04

ARG BEATS_VER=7.4.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Beats/${BEATS_VER}/patch"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:/usr/local/go/bin/:$GOPATH/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    acl \
    gcc \
    git \
    libcap-dev \
    libpcap0.8-dev \
    libssh-dev \
    make \
    openssl \
    python  \
    python-openssl \
    python-setuptools \
    tar \
    wget \
    libsystemd-dev \
# Install go and download beats source code
 && wget https://storage.googleapis.com/golang/go1.12.9.linux-s390x.tar.gz \
 && chmod ugo+r go1.12.9.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.12.9.linux-s390x.tar.gz \
 && python -m easy_install pip \
 && python -m pip install appdirs pyparsing six packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v${BEATS_VER}  \
# Building auditbeat
 && wget ${PATCH_URL}/endian.go -P $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/ \
 && wget ${PATCH_URL}/patch.diff \
 && git apply --ignore-whitespace patch.diff \
# Building heartbeat
 && cd $GOPATH/src/github.com/elastic/beats/heartbeat  \
 && make  heartbeat \
# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make  filebeat \
# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make  packetbeat \
# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && make  metricbeat \
# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make libbeat \
# Building journalbeat
 && cd $GOPATH/src/github.com/elastic/beats/journalbeat  \
 && make journalbeat \
# Building auditbeat
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make auditbeat \
 && cp -r $GOPATH/src/github.com/elastic/beats /opt/beats \
 && ln -s /opt/beats/heartbeat/heartbeat /usr/bin/heartbeat \
 && ln -s /opt/beats/packetbeat/packetbeat /usr/bin/packetbeat \
 && ln -s /opt/beats/libbeat/libbeat /usr/bin/libbeat \
 && ln -s /opt/beats/metricbeat/metricbeat /usr/bin/metricbeat \
 && ln -s /opt/beats/filebeat/filebeat /usr/bin/filebeat \
 && ln -s /opt/beats/auditbeat/auditbeat /usr/bin/auditbeat \
 && ln -s /opt/beats/journalbeat/journalbeat /usr/bin/journalbeat \
# Tidy and clean up
 && apt-get remove -y \
    acl \
    git \
    libssh-dev \
    make \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* $SOURCE_DIR \
 && mkdir /Beats \
 && cd /opt/beats \
 && cp -n **/*.yml /Beats

# Create mount point for configuration files
VOLUME /Beats

CMD $BEATSNAME -e -path.config /Beats -d "publish"

