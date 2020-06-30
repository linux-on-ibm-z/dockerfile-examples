# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Beats 7.7.1 #############################
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
# docker run --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host -e --strict.perms=false --name <container_name> -e BEATSNAME=auditbeat -d <image_name>
###########################################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder

ARG BEATS_VER=7.7.1

# The author
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Beats/${BEATS_VER}/patch"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:/usr/local/go/bin/:$GOPATH/bin:/usr/local/bin

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
    libjpeg-dev \
    python3-venv \
    tar \
    wget \
    libsystemd-dev \
    locales \
    libffi-dev \
# Install go and download beats source code
 && locale-gen "en_US.UTF-8" \
 && locale-gen "en_GB.UTF-8" \
 && wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz \
 && tar -xzf Python-3.8.3.tgz \
 && cd Python-3.8.3 \
 && ./configure --prefix=/usr/local --exec-prefix=/usr/local \
 && make \
 && make install \
 && python3 -V \
 && python3 -m pip install appdirs pyparsing six packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv pillow \

 && wget https://dl.google.com/go/go1.13.9.linux-s390x.tar.gz \
 && chmod ugo+r go1.13.9.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.13.9.linux-s390x.tar.gz \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v${BEATS_VER}  \
# Patching Beats dir
 && wget ${PATCH_URL}/beats.patch \
 && git apply --ignore-whitespace beats.patch \
# Building heartbeat
 && cd $GOPATH/src/github.com/elastic/beats/heartbeat  \
 && make  heartbeat \
 && make  update \
 && make  fmt \
# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make  filebeat \
 && make  update \
 && make  fmt \
# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make  packetbeat \
 && make  update \
 && make  fmt \
# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && make  metricbeat \
 && make  update \
 && make  fmt \
# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make libbeat \
 && make  update \
 && make  fmt \
# Building journalbeat
 && cd $GOPATH/src/github.com/elastic/beats/journalbeat  \
 && make journalbeat \
 && make  update \
 && make  fmt \
# Building auditbeat
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make auditbeat \ 
 && make update \
 && make  fmt \
# Patching for auditbeat fixes
 && cd $GOPATH/pkg/mod/github.com/elastic/go-libaudit@v0.4.0 \
 && wget ${PATCH_URL}/audit.patch \
 && patch -i audit.patch \
 && wget ${PATCH_URL}/endian.go -P $GOPATH/pkg/mod/github.com/elastic/go-libaudit@v0.4.0 \
 && cd $GOPATH/pkg/mod/github.com/elastic/go-libaudit@v0.4.0/rule \
 && wget $PATCH_URL/binary.patch \
 && patch -i binary.patch \
# Building auditbeat to reflect fixes
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make clean \
 && make auditbeat \ 
 && make update \
 && make  fmt

FROM s390x/ubuntu:18.04

WORKDIR /Beats

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

COPY --from=builder /tmp/source/src/github.com/elastic/beats/heartbeat/heartbeat /usr/bin/heartbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/packetbeat/packetbeat /usr/bin/packetbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/libbeat/libbeat /usr/bin/libbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/metricbeat/metricbeat /usr/bin/metricbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/filebeat/filebeat /usr/bin/filebeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/auditbeat/auditbeat /usr/bin/auditbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/journalbeat/journalbeat /usr/bin/journalbeat
COPY --from=builder /tmp/source/src/github.com/elastic/beats/**/*.yml /Beats/

RUN apt-get update && apt-get install -y libpcap0.8

# Create mount point for configuration files
VOLUME /Beats

CMD $BEATSNAME -e -c /Beats/${BEATSNAME}.yml -d "publish"
#End of Dockerfile
