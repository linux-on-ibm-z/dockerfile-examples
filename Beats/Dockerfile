# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Beats 7.10.1 #############################
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

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG BEATS_VER=7.10.1

# The author
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Beats/${BEATS_VER}/patch"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:/usr/local/go/bin/:$GOPATH/bin:/usr/local/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    make \
    wget \
    tar \
    gcc \
    libcap-dev \
    libpcap0.8-dev \
    openssl \
    libssh-dev \
    acl \
    rsync \
    patch \
    fdclone \
    libffi-dev \
    libsystemd-dev \
    libjpeg-dev \
    libpython3-dev \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3-lib2to3 \
    python3-distutils \
# Install go and download beats source code
 && /usr/bin/update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10 \
 && /usr/bin/update-alternatives --set python3 /usr/bin/python3.8 \
 && /usr/bin/update-alternatives --display python3 \
 && python3 -V \
 && wget https://bootstrap.pypa.io/get-pip.py \
 && python3 get-pip.py \
 && rm get-pip.py \
 && cd $SOURCE_DIR \
 && wget -O rustup-init.sh https://sh.rustup.rs \
 && bash rustup-init.sh -y \
 && export PATH=$PATH:$HOME/.cargo/bin \
 && python3 -m pip install appdirs pyparsing packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv pillow \
 && wget https://dl.google.com/go/go1.14.7.linux-s390x.tar.gz \
 && chmod ugo+r go1.14.7.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.14.7.linux-s390x.tar.gz \
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
 && make heartbeat \
 && make update \
 && make fmt \
# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make filebeat \
 && make update \
 && make fmt \
# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make packetbeat \
 && make update \
 && make fmt \
# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && mage build \
 && mage update \
 && mage fmt \
# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make libbeat \
 && make update \
 && make fmt \
# Building journalbeat
 && cd $GOPATH/src/github.com/elastic/beats/journalbeat  \
 && make journalbeat \
 && make update \
 && make fmt \
# Building auditbeat
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make auditbeat \ 
 && make update \
 && make fmt 

FROM s390x/ubuntu:18.04

WORKDIR /Beats

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

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
