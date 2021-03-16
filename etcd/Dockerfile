# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for etcd 3.4.15 ####################
#
# This Dockerfile builds a basic installation of etcd.
#
# etcd is a distributed key value store that provides a reliable way to store data across a 
# cluster of machines.Your applications can read and write data into etcd. A simple use-case is to store database connection 
# details or feature flags in etcd as key value pairs. 
# These values can be watched, allowing your app to reconfigure itself when they change.
# 
# docker build -t <image_name> .
#
# To start a container with etcd image.
# docker run --name <container_name> -p 2379:2379 -p 2380:2380 -it <image_name> /bin/bash
#
# Use below command to use etcd
# docker rune> -v <ho  --name <container_namst_path_dir>:/data -p 2379:2379 -p 2380:2380 -d <image_name>
#
#
###########################################################################

# Base image
FROM s390x/ubuntu:18.04 as builder

ARG ETCD_VER=v3.4.15
ARG GO_VER=1.13.15

# Maintainer
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH=$PATH:/usr/local/go/bin GOPATH=/
ENV ETCD_DATA_DIR=/data

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    gcc \
    tar \
    wget \
# Install GO 
 && wget https://dl.google.com/go/go${GO_VER}.linux-s390x.tar.gz \
 && chmod ugo+r go${GO_VER}.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go${GO_VER}.linux-s390x.tar.gz \
# Clone etcd source
 && mkdir -p /src/github.com/etcd-io \
 && cd /src/github.com/etcd-io \
 && git clone http://github.com/etcd-io/etcd \
 && cd etcd \
 && git checkout ${ETCD_VER} \
 && mkdir -p /data \
# Build
 && go mod vendor \
 && ./build
 
FROM s390x/ubuntu:18.04

# Maintainer
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH=$PATH:/usr/local/go/bin ETCD_UNSUPPORTED_ARCH=s390x ETCD_DATA_DIR=/data
COPY --from=builder /src/github.com/etcd-io/etcd/bin/etcd /usr/local/bin/
COPY --from=builder /src/github.com/etcd-io/etcd/bin/etcdctl /usr/local/bin/
RUN mkdir -p /var/etcd/  \
    && mkdir -p /var/lib/etcd/  \
    && mkdir -p /data
COPY --from=builder /usr/local/go/bin /usr/local/go/bin
EXPOSE 2379 2380

CMD ["/usr/local/bin/etcd"]
# End of Dockerfile
