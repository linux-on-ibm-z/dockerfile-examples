# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################### Dockerfile for Consul - 1.9.2 ########################
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
FROM s390x/ubuntu:20.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV CONSUL_VERSION=1.9.2

# Set GO environment variables
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH $SOURCE_DIR
ENV PATH=$GOPATH/go/bin:$GOPATH/bin:$PATH

# Installing dependencies for Consul
RUN apt-get update &&  apt-get install -y \
    curl \
    iproute2 \
    gcc \
    git \
    make \
    tar \
    wget \
    rsyslog \
    patch \
# Start syslog server
 && service rsyslog start \
# Install go and get source code of consul
 && cd $SOURCE_DIR \
 && wget https://golang.org/dl/go1.15.7.linux-s390x.tar.gz \
 && tar -xzf go1.15.7.linux-s390x.tar.gz \ 
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/consul.git \
 && cd consul && git checkout v${CONSUL_VERSION} \
# Build consul
 && make tools \
 && make dev

FROM s390x/alpine:3.12

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup consul && \
    adduser -S -G consul consul

RUN set -eux && \
    apk add --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec iputils jq libc6-compat

COPY --from=builder /tmp/source/src/github.com/hashicorp/consul/bin/consul /usr/local/bin/
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul 
    
# set up nsswitch.conf for Go's "netgo" implementation which is used by Consul,
# otherwise DNS supercedes the container's hosts file, which we don't want.
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

# Expose the consul data directory as a volume since there's mutable state in there.
VOLUME /consul/data

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

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-dev", "-client", "0.0.0.0"]
