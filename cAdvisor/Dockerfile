# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################## Dockerfile for cAdvisor 0.36.0 #################################
#
# This Dockerfile builds a basic installation of cAdvisor.
#
# cAdvisor (Container Advisor) provides container users an understanding of the resource usage
# and performance characteristics of their running containers. It is a running daemon that collects,
# aggregates, processes, and exports information about running containers.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start cAdvisor server create a container from the image created from Dockerfile and
# link 8080 to the port.
# docker run --name <container_name> -p <port_number>:8080 -d <image_name>
#
# Access cAdvisor web user interface from browser
# http://<hostname>:<port_number>
#
##########################################################################################

# Base image
FROM s390x/ubuntu:20.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG CADVISOR_VER=0.36.0

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Set Environmental Variables
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:$GOPATH/bin
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
        curl \
        patch \
        golang-1.14 \
        make \
 && export PATH=/usr/lib/go-1.14/bin/:$PATH \
# Create directory and Change the work directory
 && mkdir -p $GOPATH/src/github.com/google && cd $GOPATH/src/github.com/google \
# Checkout the code from repository
 && git clone https://github.com/google/cadvisor.git -b v$CADVISOR_VER \
 && cd cadvisor \
# Change the work directory
 && cd $GOPATH/src/github.com/google/cadvisor \
# Apply patches 
 && export PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/cAdvisor/0.36.0/patch" \
 && curl -o "go_mod.patch" $PATCH_URL/go_mod.patch \
 && curl -o "go_sum.patch" $PATCH_URL/go_sum.patch \
 && patch --ignore-whitespace go.mod < go_mod.patch \
 && patch --ignore-whitespace go.sum < go_sum.patch \
# Build cadvisor
 && cd $GOPATH/src/github.com/google/cadvisor \
 && make build . \
 && cp $GOPATH/src/github.com/google/cadvisor/cadvisor /usr/bin \
 && cd && rm -rf $SOURCE_DIR \
 && apt-get remove -y git && apt-get autoremove -y && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Multistage build
FROM s390x/ubuntu:20.04

WORKDIR /root
COPY --from=builder /usr/bin/cadvisor /usr/bin/cadvisor
# Port for cAdvisor
EXPOSE 8080

# Command to execute
CMD ["/usr/bin/cadvisor"]

# End of Dockerfile
