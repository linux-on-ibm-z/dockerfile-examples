# © Copyright IBM Corporation 2020, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 24.1.4 ####################################
#
# To build CockroachDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# For more information to setup cluster, visit
# https://www.cockroachlabs.com/docs/stable/start-a-local-cluster-in-docker-linux.html
#
####################################################################################################################

# Base image
FROM s390x/ubuntu:20.04 AS builder

# CockroachDB version
ARG CRDB_VER=24.1.4
ARG PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/${CRDB_VER}

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN apt-get update \
&& apt-get install -y sudo wget \
&& useradd -m build_user \
&& usermod -aG sudo build_user \
# disable sudo password
&& echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# CockroachDB dev script cannot be run by root user
USER build_user

# Set PATH
ENV SOURCE_ROOT=/home/build_user
SHELL ["/bin/bash", "-c"]

WORKDIR $SOURCE_ROOT

ENV USER=build_user
RUN cd $SOURCE_ROOT \
&& wget $PATCH_URL/build_crdb.sh \
&& bash build_crdb.sh -y

# Build a fresh image without all the build requirements
FROM registry.access.redhat.com/ubi9/ubi-minimal

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH=/usr/local/go/bin:/cockroach:$PATH

RUN microdnf update -y \
    && microdnf install sudo tzdata hostname tar wget cmake gcc-c++ keyutils-libs-devel -y \
    && mkdir -p /cockroach \
    && mkdir -p /usr/local/lib/cockroach \
    && mkdir -p /docker-entrypoint-initdb.d

RUN wget https://ftp.samba.org/pub/cwrap/resolv_wrapper-1.1.8.tar.gz \
&& tar zxf resolv_wrapper-1.1.8.tar.gz \
&& cd resolv_wrapper-1.1.8 && mkdir obj && cd obj \
&& cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
&& make \
&& sudo make install

RUN wget -O /cockroach/cockroach.sh https://raw.githubusercontent.com/cockroachdb/cockroach/v24.1.4/build/deploy/cockroach.sh

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
