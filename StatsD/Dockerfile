# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for statsd 0.8.1 ####################
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
#  docker run  --name <container_name> -v $PWD/config:/etc/statsd  -p 8126:8126 -p 8125:8125/udp -d <image_name>
#
###########################################################################

# Base image
FROM s390x/ubuntu:16.04

ARG STATSD_VER=v0.8.1

# Maintainer
MAINTAINER LoZ Open Source Ecosystem

ENV SOURCE_DIR=/tmp/source
ENV PATH=$PATH:$SOURCE_DIR/node-v6.12.2-linux-s390x/bin
WORKDIR $SOURCE_DIR

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
    && wget https://nodejs.org/dist/v6.12.2/node-v6.12.2-linux-s390x.tar.gz \
    && tar -xvf node-v6.12.2-linux-s390x.tar.gz \
    && node -v \

    # Clone statsd
    &&  git clone https://github.com/etsy/statsd.git \
    &&  cd statsd \
    &&  git checkout $STATSD_VER \
    &&  npm install \
    &&  mkdir -p /etc/statsd \
    &&  cp -v exampleConfig.js /etc/statsd/config.js  

WORKDIR $SOURCE_DIR/statsd

EXPOSE 8125/udp
EXPOSE 8126

ENTRYPOINT [ "node", "stats.js", "/etc/statsd/config.js" ]
# End of Dockerfile
