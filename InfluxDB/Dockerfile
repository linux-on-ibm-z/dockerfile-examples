# © Copyright IBM Corporation 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for InfluxDB 1.8.2 ############################s
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
# $ docker run -p <port>:8086 \
#     -v $PWD:/var/lib/influxdb \
#     <image_name>
#
# Modify $PWD to the directory where you want to store data associated with the
# InfluxDB container.
#
# For more information, see https://hub.docker.com/_/influxdb
###############################################################################

# Builder image
FROM s390x/ubuntu:20.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Environment
ARG VERSION=1.8.2
ENV SOURCE_ROOT=/tmp
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/InfluxDB/${VERSION}/patch"

WORKDIR /tmp

RUN apt-get update \
&&  apt-get install -y git gcc g++ wget patch \
### Install Go ##########################################
&&  cd $SOURCE_ROOT \
&&  wget https://storage.googleapis.com/golang/go1.13.14.linux-s390x.tar.gz \
&&  tar -C /usr/local -xzf go1.13.14.linux-s390x.tar.gz \
&&  export PATH=/usr/local/go/bin:$PATH \
### Build InfluxDB ###########################################
&&  export GO111MODULE=on \
&&  git clone https://github.com/influxdata/influxdb.git \
&&  cd influxdb && git checkout v${VERSION} \
&&  wget $PATCH_URL/patch_functions.diff \
&&  patch --ignore-whitespace query/functions.go < patch_functions.diff \
&&  go clean ./... \
&&  go build ./... \
&&  go install -ldflags="-X main.version=v${VERSION}" ./...

# Base image
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG VERSION=1.8.2

COPY --from=builder /root/go/bin/* /usr/bin/
COPY --from=builder /tmp/influxdb/etc/config.sample.toml /etc/influxdb/influxdb.conf

EXPOSE 8086
VOLUME /var/lib/influxdb

COPY ./entrypoint.sh /
COPY ./init-influxdb.sh /
RUN chmod +x /entrypoint.sh /init-influxdb.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]

# End of Dockerfile
