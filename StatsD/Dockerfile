# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for statsd 0.8.2 ####################
#
# This Dockerfile builds a basic installation of statsd.
#
# StatsD is a front-end proxy for the Graphite/Carbon metrics server.
# docker build -t <image_name> .
#
# To start a container with statsd image.
# docker run --name <container_name> -p 8126:8126 -p 8125:8125/udp  -it <image_name> /bin/bash
#
# Use below command to use statsd
# docker run  --name <container_name>  -p 8126:8126 -p 8125:8125/udp  -d <image_name>
#
#  Use below command to pass the configuration using volume and start the statsd service
#  docker run  --name <container_name> -v <host_path>/config.js:/opt/statsd/config.js  -p 8126:8126 -p 8125:8125/udp -d <image_name>
#
###########################################################################

# Base image
FROM s390x/ubuntu:16.04

ARG STATSD_VER=v0.8.2

# Maintainer
MAINTAINER LoZ Open Source Ecosystem

ENV SOURCE_ROOT=/opt
ENV PATH=$PATH:$SOURCE_ROOT/node-v10.15.3-linux-s390x/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    g++ \
    git \
    hostname \
    make \
    python \
    tar \
    unzip \
    wget \
# Install Nodejs
    && cd $SOURCE_ROOT \
    && wget https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-s390x.tar.gz \
    && tar -C $SOURCE_ROOT -xvf node-v10.15.3-linux-s390x.tar.gz \
# Clone statsd
    && cd $SOURCE_ROOT \
    && git clone https://github.com/etsy/statsd.git \
    && cd statsd \
    && git checkout $STATSD_VER \
    && npm install --unsafe-perm=true \
    && cp -v exampleConfig.js config.js \
    && sed -i 's/graphite.example.com/graphite/' config.js \
# Clean up unused packages and data
    && apt-get remove -y \
    g++ \
    git \
    make \
    python \
    unzip \
    wget \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* $SOURCE_ROOT/node-v10.15.3-linux-s390x.tar.gz

WORKDIR $SOURCE_ROOT/statsd

# Expose required ports
EXPOSE 8125/udp
EXPOSE 8126

# Start statsd
ENTRYPOINT [ "node", "stats.js", "config.js" ]
# End of Dockerfile
