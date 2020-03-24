# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################### Dockerfile for Consul - 1.7.1 ########################
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
FROM s390x/ubuntu:18.04 AS builder

ARG CONSUL_VER=1.7.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

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
    wget \
    rsyslog \

# Start syslog server
 && service rsyslog start \

# Install go and get source code of consul
 && cd $SOURCE_DIR \
 && wget https://storage.googleapis.com/golang/go1.13.7.linux-s390x.tar.gz \
 && tar -xzf go1.13.7.linux-s390x.tar.gz \ 
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/consul.git \
 && cd consul && git checkout tags/v${CONSUL_VER} \
 
# Build consul
 && make tools \
 && make dev
 
FROM s390x/ubuntu:18.04
RUN apt-get update -y

WORKDIR /root
COPY --from=builder /tmp/source/src/github.com/hashicorp/consul/bin/consul /usr/local/bin/consul
RUN mkdir -p /consul/data 

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
