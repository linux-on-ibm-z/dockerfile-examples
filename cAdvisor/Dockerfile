# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################## Dockerfile for cAdvisor 0.49.2 #################################
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
# docker run --privileged --name <container_name> -p <port_number>:8080 -d <image_name>
#
# Access cAdvisor web user interface from browser
# http://<hostname>:<port_number>
#
##########################################################################################

# Base image
FROM s390x/golang:1.22-alpine3.18 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG CADVISOR_VER=0.49.2

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apk update && apk add --no-cache \
    git \
    curl \
    patch \
    make \
    gcc \
    sudo \
    wget \
    musl-dev \
 && apk add --no-cache --upgrade bash \
# Checkout the code from repository
 && git clone -b v$CADVISOR_VER https://github.com/google/cadvisor.git \
# Build cadvisor
 && cd cadvisor \
 && make build \
 && cp ./_output/cadvisor /usr/bin \
 && cd && rm -rf $SOURCE_DIR \
 && apk del git

# Multistage build
FROM s390x/alpine:3.18
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
WORKDIR /root
COPY --from=builder /usr/bin/cadvisor /usr/bin/cadvisor
# Port for cAdvisor
EXPOSE 8080

ENV CADVISOR_HEALTHCHECK_URL=http://localhost:8080/healthz

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider $CADVISOR_HEALTHCHECK_URL || exit 1

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]

# End of Dockerfile

