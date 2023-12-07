# © Copyright IBM Corporation 2023
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################### Dockerfile for Salt version v3006 ##################################
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
#
# To start container from image & start an application in production mode
# docker run -v <host_path>:/etc/salt -d <image>
# 
# The official website
# https://saltstack.com/
#
##################################################################################

# Stage 1: Builder stage
FROM ubuntu:20.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

ARG SALT_VER=v3006.3

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3 \
    python3-pip \
    libffi-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository and install SaltStack
RUN git clone --branch $SALT_VER --depth 1 https://github.com/saltstack/salt.git salt \
    && cd salt \
    && pip3 install . \
    && cd ..

# Stage 2: Final stage
FROM ubuntu:20.04

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Copy SaltStack binaries from builder stage
COPY --from=builder $SOURCE_DIR/salt /salt

# Create necessary directories and configure SaltStack
RUN mkdir -p etc/salt/pki/master \
    && mkdir -p etc/salt/pki/minion

# Copy SaltStack configuration files
COPY --from=builder /salt/conf/master /etc/salt/master
COPY --from=builder /salt/conf/minion /etc/salt/minion

# Update configuration files for SaltStack
RUN sed -i 's/#user: root/user: root/g' /etc/salt/master \
    && sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' /etc/salt/master \
    && sed -i 's,#pki_dir: /,'"pki_dir: $SOURCE_DIR/etc/salt/pki/master"',' /etc/salt/master \
    && sed -i 's/#master: salt/master: localhost/g' /etc/salt/minion \
    && sed -i 's/#user: root/user: root/g' /etc/salt/minion \
    && sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' /etc/salt/minion \
    && sed -i 's,#pki_dir: /,'"pki_dir: $SOURCE_DIR/etc/salt/pki/minion"',' /etc/salt/minion \
    && sed -i 's,#id:,'"id: saltdev"',' /etc/salt/minion

# Clean up unnecessary dependencies
RUN apt-get update && apt-get remove -y \
    git \
    build-essential \
    python3-pip \
    libffi-dev \
    libssl-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Start SaltStack services
CMD salt-master -c ./etc/salt & salt-minion -c ./etc/salt
