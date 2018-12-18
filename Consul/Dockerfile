# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Consul - 1.4.0 #########
# 
# Consul is a tool for service discovery and configuration. Consul is distributed, highly available, and extremely scalable.
# Consul provides several key features like Service Discovery, Health Checking , Key/Value Storage , Multi-Datacenter 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .

# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use Consul:
# docker run --name <container_name> -it <image_name> consul <argument>
#
# Use below command to start the Consul agent in development mode :
# docker run --name consultest -d consul consul agent -dev
#
# Follow link to setup Consul cluster: https://www.consul.io/intro/getting-started/join.html
#####################################################################

# Base image
FROM s390x/ubuntu:16.04

ARG CONSUL_VER=1.4.0

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set GO environment variables
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH $SOURCE_DIR
ENV PATH=$GOPATH/go/bin:$GOPATH/bin:$PATH

# Installing dependencies for Consul
RUN apt-get update &&  apt-get install -y \
    curl \
    gcc \
    git \
    make \
    tar \
    unzip \
    vim \
    wget \
    zip \
# Install go and get source code of consul
 && cd $SOURCE_DIR \
 && wget https://storage.googleapis.com/golang/go1.11.1.linux-s390x.tar.gz \
 && tar -xzf go1.11.1.linux-s390x.tar.gz \
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/consul.git \
 && cd consul && git checkout tags/v${CONSUL_VER} \
 && go get -u github.com/SAP/go-hdb/... \
 && mv $GOPATH/src/github.com/hashicorp/consul/vendor/github.com/SAP/go-hdb $GOPATH/src/github.com/hashicorp/consul/vendor/github.com/SAP/go-hdb_bkp \
 && cp -r $GOPATH/src/github.com/SAP/go-hdb $GOPATH/src/github.com/hashicorp/consul/vendor/github.com/SAP/ \
# Build consul
 && make dev \
 && cp $GOPATH/bin/consul /usr/local/bin \
 && mkdir -p /consul/data \
# Tidy and clean up
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
   curl \
   git \
   gcc \
   vim \
   wget \
   zip \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create Volume
VOLUME ["/consul/data"]

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8500 8600 8600/udp

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
