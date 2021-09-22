# © Copyright IBM Corporation 2020, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 21.1.7 ####################################
#
# To build CockroachDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start a single node CockroachDB server for testing run the below command
# docker run --name <container_name> -p <port_number>:26257 -p <port_number>:8080 -d <image_name> start-single-node --insecure
#
#
# To see the UI, go to http://<hostname>:<port_number>/ on web browser.
# For more information to setup cluster, visit https://www.cockroachlabs.com/docs/stable/start-a-local-cluster.html
#
####################################################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder

# CockroachDB version
ARG CRDB_VER=21.1.7

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set PATH
ENV SOURCE_DIR=/root
ENV PATH=/usr/local/node-v12.20.1-linux-s390x/bin:/usr/local/go/bin:$PATH GOPATH=$WORKDIR

WORKDIR $SOURCE_DIR

# Install following build dependencies
RUN apt-get update \
&& apt-get install -y g++ autoconf automake cmake wget libncurses5-dev bison xz-utils patch git curl \
# Install Golang
&& cd $SOURCE_DIR \
&& wget https://storage.googleapis.com/golang/go1.15.14.linux-s390x.tar.gz \
&& tar -C /usr/local -xzf go1.15.14.linux-s390x.tar.gz \
# Install Nodejs and yarn
&& wget https://nodejs.org/dist/v12.20.1/node-v12.20.1-linux-s390x.tar.xz \
&& chmod ugo+r node-v12.20.1-linux-s390x.tar.xz \
&& tar -C /usr/local -xf node-v12.20.1-linux-s390x.tar.xz \
&& env PATH=$PATH npm install -g yarn \
# Download and Install CockroachDB
&& cd $SOURCE_DIR \
&& mkdir -p $(go env GOPATH)/src/github.com/cockroachdb \
&& cd $(go env GOPATH)/src/github.com/cockroachdb \
&& git clone https://github.com/cockroachdb/cockroach \
&& cd cockroach \
&& git checkout v$CRDB_VER \
&& git submodule update --init --recursive \
&& curl -sSL https://github.com/apache/arrow/commit/aca707086160afd92da62aa2f9537a284528e48a.patch | git apply --directory=vendor/github.com/apache/arrow --exclude '**/array/bufferbuilder_numeric_test.go' - \
&& make build \
&& make install \
&& mkdir -p /usr/local/lib/cockroach \
&& cp lib/libgeos.so /usr/local/lib/cockroach/ \
&& cp lib/libgeos_c.so /usr/local/lib/cockroach/

# Build a fresh image without all the build requirements
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH=/usr/local/go/bin:/cockroach:$PATH

RUN apt-get update && apt-get install -y tzdata hostname tar \
    && mkdir -p /cockroach \
    && mkdir -p /usr/local/lib/cockroach
COPY cockroach.sh /cockroach/
COPY --from=builder /usr/local/bin/cockroach  /cockroach/
COPY --from=builder /usr/local/lib/cockroach/libgeos.so /usr/local/lib/cockroach/
COPY --from=builder /usr/local/lib/cockroach/libgeos_c.so /usr/local/lib/cockroach/
RUN chmod +x /cockroach/cockroach.sh

WORKDIR /cockroach/

# Include the directory in the path to make it easier to invoke
# commands via Docker
ENV PATH=/cockroach:$PATH

# Expose ports
EXPOSE 26257 8080

ENTRYPOINT ["/cockroach/cockroach.sh"]
