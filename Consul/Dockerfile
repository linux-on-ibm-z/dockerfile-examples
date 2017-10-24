########## Dockerfile for Consul - 0.9.3 #########
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
# Below is an example to display the installed Consul help :
# docker run --name <container_name> -it <image_name> consul help
#
# Follow link to setup Consul cluster: https://www.consul.io/intro/getting-started/join.html
#####################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set GO environment variables
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH $SOURCE_DIR
ENV PATH=$PATH:$GOPATH/bin:$GOPATH/go/bin
ENV GOROOT=$GOPATH/go
ENV CC=gcc


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

# Clone go and consul
 && cd $SOURCE_DIR \
 && wget https://storage.googleapis.com/golang/go1.8.3.linux-s390x.tar.gz \
 && tar -xzf go1.8.3.linux-s390x.tar.gz \
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/consul.git \
 && cd consul && git checkout tags/v0.9.3 \
 && go get github.com/mitchellh/gox \

# Apply the patch to add s390x support
 && cd $GOPATH/src/github.com/mitchellh/gox \
 && wget https://github.com/mitchellh/gox/pull/85.patch \
 && git config user.email "lozopensource@github.com" \
 && git config user.name "LoZ" \
 && git am 85.patch \
# Reinstall gox tool
 && cd $GOPATH/src/github.com/mitchellh/ \
 && go install ./... \
 && cd $GOPATH/src/github.com/hashicorp/consul \

# Build consul
 && gox -os=linux -arch=s390x -output=s390x/consul \
 && cp $GOPATH/src/github.com/hashicorp/consul/s390x/consul /usr/local/bin \
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
