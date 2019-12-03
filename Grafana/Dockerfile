# Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Grafana 6.4.2 ############################################
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
FROM s390x/ubuntu:18.04 as builder

ARG GRAFANA_VER=6.4.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV QT_QPA_PLATFORM=offscreen GOPATH=/opt
ENV PATH=$PATH:/usr/local/node-v10.16.3-linux-s390x/bin:/usr/local/go/bin:/usr/share/grafana/bin/linux-s390x

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    gcc \
    git \
    make \
    phantomjs \
    python \
    wget \
    unzip \
# Install go
 && cd $GOPATH \
 && wget https://storage.googleapis.com/golang/go1.12.9.linux-s390x.tar.gz \
 && chmod ugo+r go1.12.9.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.12.9.linux-s390x.tar.gz \
# Install Nodejs
 && cd $GOPATH \
 && wget https://nodejs.org/dist/v10.16.3/node-v10.16.3-linux-s390x.tar.xz \
 && chmod ugo+r node-v10.16.3-linux-s390x.tar.xz \
 && tar -C /usr/local -xf node-v10.16.3-linux-s390x.tar.xz \
# Get the Grafana Soure code and build Grafana backend
 && git clone https://github.com/grafana/grafana.git $GOPATH/src/github.com/grafana/grafana \
 && cd $GOPATH/src/github.com/grafana/grafana && git checkout v${GRAFANA_VER} \
 && make deps-go \
 && make build-go \
# Install yarn
 && npm install -g yarn \
# Build frontend
 && cd $GOPATH/src/github.com/grafana/grafana \
 && make deps-js \
 && make build-js 

# Build a fresh image without all the build requirements

FROM s390x/ubuntu:18.04

RUN apt-get update -y 

ENV BASE=/opt/src/github.com/grafana/grafana 

COPY --from=builder $BASE/public/		/usr/share/grafana/public/
COPY --from=builder $BASE/conf/		/usr/share/grafana/conf/
COPY --from=builder $BASE/bin/linux-s390x/grafana-cli		/usr/sbin/
COPY --from=builder $BASE/bin/linux-s390x/grafana-server	/usr/sbin/

VOLUME ["/usr/share/grafana/conf","/usr/share/grafana/data"]

EXPOSE 3000
WORKDIR "/usr/share/grafana/"

ENTRYPOINT grafana-server start
# End of Dockerfile
