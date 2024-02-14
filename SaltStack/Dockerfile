# © Copyright IBM Corporation 2023, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################### Dockerfile for Salt version v3006.5 ##################################
#
# This Dockerfile builds a basic installation of Salt.
#
# SaltStack makes software for complex systems management at scale.
# SaltStack is the company that created and maintains the Salt Open project and develops and sells SaltStack Enterprise software, services and support.
# Salt is a new approach to infrastructure management built on a dynamic communication bus.
# Salt can be used for data-driven orchestration, remote execution for any infrastructure, configuration management for any app stack, and much more.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start container from image & start an application in production mode
# docker run -d <image>
#
# The official website
# https://saltstack.com/
#
##################################################################################

FROM ubuntu:20.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

ARG SALT_VER=v3006.5

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3 \
    python3-pip \
    libffi-dev \
    libssl-dev \
# Clone the repository and install SaltStack
    && mkdir -p /etc/salt \
    && git clone https://github.com/saltstack/salt.git salt \
    && cd salt \
    && git checkout $SALT_VER \
    && pip3 install . \
    && cd .. \
    && rm -rf salt \
# Clean dependencies
apt-get update && apt-get remove -y \
    git \
    build-essential \
    python3-pip \
    libffi-dev \
    libssl-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/master /etc/salt/
COPY conf/minion /etc/salt/

# Start SaltStack services
CMD salt-master -c /etc/salt & salt-minion -c /etc/salt
