# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for etcd 3.3.4 ####################
#
# This Dockerfile builds a basic installation of etcd.
#
# etcd is a distributed key value store that provides a reliable way to store data across a 
# cluster of machines.Your applications can read and write data into etcd. A simple use-case is to store database connection 
# details or feature flags in etcd as key value pairs. 
# These values can be watched, allowing your app to reconfigure itself when they change.
# 
# docker build -t <image_name> .
#
# To start a container with etcd image.
# docker run --name <container_name> -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 -it <image_name> /bin/bash
#
# Use below command to use help option for etcd
# docker run  --name <container_name> -v <host_path_dir>:/data -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 -d <image_name>
#
#
###########################################################################

# Base image
FROM s390x/ubuntu:16.04

# Maintainer
MAINTAINER LoZ Open Source Ecosystem

ENV PATH=$PATH:/usr/lib/go-1.9/bin GOPATH=/
ENV ETCD_DATA_DIR=/data ETCD_UNSUPPORTED_ARCH=s390x

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    gcc \
    tar \
    wget \
    golang-1.9 \

# Clone etcd source
 && mkdir -p /src/github.com/coreos \
 && cd /src/github.com/coreos \
 && rm -rf etcd \
 && git clone git://github.com/coreos/etcd \
 && cd etcd \
 && git checkout v3.3.4 \
 && mkdir -p /data \

# Build
 && ./build \
 && cd bin && cp -rf etcd etcdctl /usr/bin/ \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    curl \
    git \
    gcc \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /src/github.com/coreos

WORKDIR /data
VOLUME /data

EXPOSE 2379 2380 4001 7001

CMD etcd

# End of Dockerfile
