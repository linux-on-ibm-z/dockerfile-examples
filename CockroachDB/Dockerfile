# © Copyright IBM Corporation 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 20.1.5 ####################################
# 
# To build CockroachDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start CockroachDB server run the below command
# docker run --name <container_name> -p <port_number>:26257 -p <port_number>:8080 -d <image_name> start --insecure
#
# To see the UI, go to http://<hostname>:<port_number>/ on web browser. 
# For more information to setup cluster, visit https://www.cockroachlabs.com/docs/stable/start-a-local-cluster.html
#
####################################################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder

# CockroachDB version
ARG CRDB_VER=20.1.5
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/20.1.5/patch"

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set PATH
ENV SOURCE_DIR=/root
ENV PATH=/usr/local/node-v12.18.2-linux-s390x/bin:/usr/local/go/bin:$PATH GOPATH=$WORKDIR

WORKDIR $SOURCE_DIR

# Install following build dependencies
RUN apt-get update \
&& apt-get install -y g++ autoconf automake cmake wget libncurses5-dev bison xz-utils patch git curl \
# Install Golang
&& cd $SOURCE_DIR \
&& wget https://storage.googleapis.com/golang/go1.13.11.linux-s390x.tar.gz \
&& tar -C /usr/local -xzf go1.13.11.linux-s390x.tar.gz \
# Install Nodejs and yarn
&& wget https://nodejs.org/dist/v12.18.2/node-v12.18.2-linux-s390x.tar.xz \
&& chmod ugo+r node-v12.18.2-linux-s390x.tar.xz \ 
&& tar -C /usr/local -xf node-v12.18.2-linux-s390x.tar.xz \
&& env PATH=$PATH npm install -g yarn \
# Download and Install CockroachDB
&& cd $SOURCE_DIR \
&& mkdir -p $(go env GOPATH)/src/github.com/cockroachdb \
&& cd $(go env GOPATH)/src/github.com/cockroachdb \
&& git clone https://github.com/cockroachdb/cockroach \
&& cd cockroach \
&& git checkout v$CRDB_VER \
&& git submodule update --init --recursive \
&& curl -sSL $PATCH_URL/cockroach.diff | git apply \
&& curl -sSL $PATCH_URL/storage.diff | git apply \
&& cd vendor && curl -sSL $PATCH_URL/vendor.diff | git apply \
&& cd .. \
&& make build \
&& make install 
 
# Build a fresh image without all the build requirements
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV PATH=/usr/local/go/bin:/cockroach:$PATH

RUN apt-get update && apt-get install -y tzdata && mkdir -p /cockroach
COPY cockroach.sh /cockroach/
COPY --from=builder /usr/local/bin/cockroach  /cockroach/ 
RUN chmod +x /cockroach/cockroach.sh

WORKDIR /cockroach/

# Expose ports
EXPOSE 26257 8080

ENTRYPOINT ["/cockroach/cockroach.sh"]
