#################### Dockerfile for Beats 6.2.2 #############################
# Beats is the platform for single-purpose data shippers
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create a container of Beats image run the below command:
# docker run --name <container_name> -it  <image_name>
#
# The following modules are present in beats: heartbeat ,filebeat ,metricbeat , packetbeat, libbeat, auditbeat
# docker run --name <container_name> -e BEATSNAME=<beat_name> -d <image_name>
#
# To run a particular module like heartbeat run the following command:
# docker run --name <container_name> -e BEATSNAME=heartbeat -d <image_name> 
#
###########################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV PATH=$PATH:/usr/lib/go-1.9/bin/
ENV GOPATH=$SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    acl \
    gcc \
    git \
	golang-1.9 \
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

# Install go and donload beats source code
 && python -m easy_install pip \
 && python -m pip install appdirs pyparsing six packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v6.2.2  \

# Building heartbeat
 && cd $GOPATH/src/github.com/elastic/beats/heartbeat  \
 && make  \

# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make  \

# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make  \

# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && make  \

# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make  \
 && cp -r $GOPATH/src/github.com/elastic/beats /opt/beats \
 && ln -s /opt/beats/heartbeat/heartbeat /usr/bin/heartbeat \
 && ln -s /opt/beats/packetbeat/packetbeat /usr/bin/packetbeat \
 && ln -s /opt/beats/libbeat/libbeat /usr/bin/libbeat \
 && ln -s /opt/beats/metricbeat/metricbeat /usr/bin/metricbeat \
 && ln -s /opt/beats/filebeat/filebeat /usr/bin/filebeat \

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
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /Beats \
 && cd /opt/beats \
 && cp -n **/*.yml /Beats

# Create mount point for configuration files
VOLUME /Beats

CMD $BEATSNAME -e -path.config /Beats -d "publish"
