# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################### Dockerfile for Consul - 1.22.4 ########################
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
FROM s390x/ubuntu:22.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG CONSUL_VERSION=1.22.4
ARG GO_VERSION=1.25.4
ENV TERM=xterm

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
    unzip \
# Start syslog server
 && rsyslogd \
# Install go and get source code of consul
 && cd $SOURCE_DIR \
 && wget https://golang.org/dl/go${GO_VERSION}.linux-s390x.tar.gz \
 && tar -xzf go${GO_VERSION}.linux-s390x.tar.gz \
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone --depth 1 -b v${CONSUL_VERSION} https://github.com/hashicorp/consul.git \
 && cd consul \
# Build consul
 && make tools \
 && make dev

FROM s390x/alpine:3.22

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
RUN addgroup consul && \
    adduser -S -G consul consul

RUN set -eux && \
    apk add --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec iputils jq libc6-compat

RUN apk update && apk add bash wget

COPY --from=builder /tmp/source/src/github.com/hashicorp/consul/bin/consul /usr/local/bin/

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.
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
RUN wget -O /usr/local/bin/docker-entrypoint.sh https://raw.githubusercontent.com/hashicorp/consul/v1.22.4/.release/docker/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-dev", "-client", "0.0.0.0"]
