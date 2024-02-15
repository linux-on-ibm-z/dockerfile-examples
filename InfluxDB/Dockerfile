# © Copyright IBM Corporation 2020, 2024
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for InfluxDB 2.7.5 ############################s
#
# Builds InfluxDB
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Running the container
#
# The InfluxDB image exposes a shared volume under /var/lib/influxdb, so you
# can mount a host directory to that point to access persisted container data.
# A typical invocation of the container might be:
#
# $ docker run --name <container_name> -p <port>:8086 -d <image_name>
#
# For more information, see https://hub.docker.com/_/influxdb
###############################################################################

# Builder image
FROM debian:bookworm-slim as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Environment
ARG VERSION=2.7.5
ENV DEBIAN_FRONTEND noninteractive
ENV SOURCE_ROOT=/tmp
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin

WORKDIR /tmp

RUN apt-get update \
&&  apt-get install -y wget clang git gcc g++ wget bzr protobuf-compiler libprotobuf-dev curl pkg-config make nodejs \
### Install Yarn ##########################################
&&  curl -o- -L https://yarnpkg.com/install.sh | bash \
&&  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" \
### Install Rust ##########################################
&&  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
&&  export PATH="$HOME/.cargo/bin:$PATH" \
### Install Go ##########################################
&&  wget https://golang.org/dl/go1.21.6.linux-s390x.tar.gz \
&&  tar -C /usr/local -xzf go1.21.6.linux-s390x.tar.gz \
&&  export PATH=/usr/local/go/bin:$PATH \
### Build InfluxDB ###########################################
&&  export GO111MODULE=on \
&&  go install github.com/influxdata/pkg-config@v0.2.13 \
&&  git clone https://github.com/influxdata/influxdb.git \
&&  cd influxdb && git checkout v${VERSION} \
&&  export NODE_OPTIONS=--max_old_space_size=4096 \
&&  make

# Base image
FROM debian:bookworm-slim

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

COPY --from=builder /tmp/influxdb/bin/linux/influxd /usr/bin/influxd

EXPOSE 8086

ENTRYPOINT [ "/usr/bin/influxd" ]

# End of Dockerfile
