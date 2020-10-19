# Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Grafana 7.0.5 ############################################
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
# Please remember to include the renderer configuration when providing a customized configuration as in the building instructions: https://github.com/linux-on-ibm-z/docs/wiki/Building-Grafana
# More information in the grafana configuration documentation: http://docs.grafana.org/installation/configuration/
################################################################################################################

# Base Image
FROM s390x/ubuntu:18.04 as builder

ARG GRAFANA_VER=7.0.5

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV GOPATH=/opt
ENV PATH=$PATH:/usr/local/node-v12.18.2-linux-s390x/bin:/usr/local/go/bin:/usr/share/grafana/bin/linux-s390x

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    gcc \
    git \
    make \
    python \
    wget \
    unzip \
# Install go
 && cd $GOPATH \
 && wget https://dl.google.com/go/go1.14.4.linux-s390x.tar.gz \
 && chmod ugo+r go1.14.4.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.14.4.linux-s390x.tar.gz \
# Install Nodejs
 && cd $GOPATH \
 && wget https://nodejs.org/dist/v12.18.2/node-v12.18.2-linux-s390x.tar.xz \
 && chmod ugo+r node-v12.18.2-linux-s390x.tar.xz \
 && tar -C /usr/local -xf node-v12.18.2-linux-s390x.tar.xz \
# Get the Grafana Soure code and build Grafana backend
 && git clone https://github.com/grafana/grafana.git $GOPATH/src/github.com/grafana/grafana \
 && cd $GOPATH/src/github.com/grafana/grafana && git checkout v${GRAFANA_VER} \
 && make deps-go \
 && make build-go \
# Install yarn
 && npm install -g yarn \
# Build Grafana-image-renderer
 && cd $GOPATH/src/github.com/grafana \
 && git clone https://github.com/grafana/grafana-image-renderer.git \
 && cd grafana-image-renderer \
 && git checkout v2.0.0 \
 && make deps \
 && make build \
# Build frontend and edit configuration
 && cd $GOPATH/src/github.com/grafana/grafana \
 && make deps-js \
 && make build-js \
 && sed -i "s/^server_url.*/server_url\ =\ http:\/\/localhost:8081\/render/" $GOPATH/src/github.com/grafana/grafana/conf/defaults.ini \
 && sed -i "s/^callback_url.*/callback_url\ =\ http:\/\/localhost:3000/" $GOPATH/src/github.com/grafana/grafana/conf/defaults.ini \
# Create a startup script
 && echo "#!/bin/bash" >> /root/startup_script.sh \
 && echo "node /usr/share/grafana-image-renderer/build/app.js server --port=8081 &" >> /root/startup_script.sh \
 && echo "grafana-server start" >> /root/startup_script.sh

# Build a fresh image without all the build requirements

FROM s390x/ubuntu:18.04

RUN apt-get update -y 

ENV BASE=/opt/src/github.com/grafana 
ENV PATH=$PATH:/usr/share/nodejs/bin

COPY --from=builder /root/startup_script.sh                   /root/startup_script.sh
COPY --from=builder /usr/local/node-v12.18.2-linux-s390x/     /usr/share/nodejs
COPY --from=builder $BASE/grafana/public/              /usr/share/grafana/public/
COPY --from=builder $BASE/grafana/conf/                /usr/share/grafana/conf/
COPY --from=builder $BASE/grafana-image-renderer/      /usr/share/grafana-image-renderer/
COPY --from=builder $BASE/grafana/bin/linux-s390x/grafana-cli       /usr/sbin/
COPY --from=builder $BASE/grafana/bin/linux-s390x/grafana-server    /usr/sbin/

VOLUME ["/usr/share/grafana/conf","/usr/share/grafana/data"]

EXPOSE 3000
WORKDIR "/usr/share/grafana/"

ENTRYPOINT bash /root/startup_script.sh
# End of Dockerfile
