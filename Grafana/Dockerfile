# Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Grafana 10.3.3 ############################################
#
# This Dockerfile builds a basic installation of Grafana.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Grafana service using this image, use following command:
# docker run --name <container name> -p <port>:3000 -d <image name>
#
# To start the Grafana service by providing configuration
# docker run --name <container_name> -v <path_to_grafana_config_file>:/usr/share/grafana/conf/custom.ini -p <port>:3000 -d <image_name>
# More information in the grafana configuration documentation: http://docs.grafana.org/installation/configuration/
################################################################################################################

# Base Image
ARG BASE_IMAGE=s390x/ubuntu:22.04
FROM ${BASE_IMAGE} AS builder

ARG GRAFANA_VER=10.3.3
ARG NODE_JS_VERSION=20.11.1
ARG GO_VERSION=1.21.4
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV GOPATH=/opt
ENV PATH=$PATH:/usr/local/node-v${NODE_JS_VERSION}-linux-s390x/bin:/usr/local/go/bin:/usr/share/grafana/bin/linux-s390x

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    gcc \
    g++ \
    git \
    make \
    wget \
    xz-utils \
    python3 \
# Install go
 && cd $GOPATH \
 && wget https://dl.google.com/go/go${GO_VERSION}.linux-s390x.tar.gz \
 && chmod ugo+r go${GO_VERSION}.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go${GO_VERSION}.linux-s390x.tar.gz \
# Install Nodejs
 && cd $GOPATH \
 && wget https://nodejs.org/dist/v${NODE_JS_VERSION}/node-v${NODE_JS_VERSION}-linux-s390x.tar.xz \
 && chmod ugo+r node-v${NODE_JS_VERSION}-linux-s390x.tar.xz \
 && tar -C /usr/local -xf node-v${NODE_JS_VERSION}-linux-s390x.tar.xz \
 # Install yarn
 && chmod ugo+w -R /usr/local/node-v${NODE_JS_VERSION}-linux-s390x/ \
 && npm install -g yarn \
 && yarn set version 4.1.0 \
# Get the Grafana Soure code and build Grafana backend
 && git clone --depth 1 -b v${GRAFANA_VER} https://github.com/grafana/grafana.git \
 && cd grafana  \
 && make gen-go \
 && make deps-go \
 && make build-go \
# Build frontend and edit configuration
 && cd $GOPATH/grafana \
 && yarn install \
 && export NODE_OPTIONS="--max-old-space-size=8192" \
 && make build-js

# Build a fresh image without all the build requirements

FROM ${BASE_IMAGE}

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV BASE=/opt
ENV PATH=$PATH:/usr/share/nodejs/bin
# Set DEBIAN_FRONTEND=noninteractive in environment at build-time
ARG DEBIAN_FRONTEND=noninteractive
ARG GF_UID="472"
ARG GF_GID="472"
ARG NODE_JS_VERSION=20.11.1

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

# Install dependencies
# We need curl in the image
RUN apt-get update && apt-get install -y ca-certificates curl tzdata libatomic1 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/*;


COPY --from=builder $BASE/grafana/public/              /usr/share/grafana/public/
COPY --from=builder $BASE/grafana/conf/                /usr/share/grafana/conf/
COPY --from=builder $BASE/grafana/bin/linux-s390x/*    /usr/share/grafana/bin/

RUN mkdir -p "$GF_PATHS_HOME/.aws" && \
    addgroup --system --gid $GF_GID grafana && \
    adduser --system --uid $GF_UID --ingroup grafana grafana && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_PROVISIONING/notifiers" \
             "$GF_PATHS_PROVISIONING/plugins" \
             "$GF_PATHS_PROVISIONING/access-control" \
             "$GF_PATHS_PROVISIONING/alerting" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" && \
    cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" && \
    chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"

EXPOSE 3000
COPY ./run.sh /run.sh

RUN chmod +x /run.sh

USER grafana
ENTRYPOINT [ "/run.sh" ]
# End of Dockerfile
