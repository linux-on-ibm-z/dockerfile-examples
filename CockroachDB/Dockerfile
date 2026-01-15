# © Copyright IBM Corporation 2020, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 25.4.2 ####################################
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
FROM registry.access.redhat.com/ubi9/ubi:9.4-1214.1729773476 AS builder

ARG CRDB_VER=25.4.2
ARG PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/refs/heads/master/CockroachDB/${CRDB_VER}

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

RUN dnf install wget sudo -y

# Install basic build tools and dependencies
RUN dnf install -y wget gcc make m4 autoconf automake libtool gettext \
    diffutils findutils

# Build and install flex from source
RUN cd /tmp \
    && wget https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz \
    && tar -xzf flex-2.6.4.tar.gz \
    && cd flex-2.6.4 \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && cd / && rm -rf /tmp/flex*

# Build and install bison from source
RUN cd /tmp \
    && wget http://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.gz \
    && tar -xzf bison-3.8.2.tar.gz \
    && cd bison-3.8.2 \
    && ./configure --prefix=/usr MAKEINFO=true \
    && make -j$(nproc) MAKEINFO=true \
    && make install \
    && cd / && rm -rf /tmp/bison*

RUN useradd -m build_user \
&& usermod -aG wheel build_user \
# disable sudo password
&& echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# CockroachDB dev script cannot be run by root user
USER build_user

# Set PATH
ENV SOURCE_ROOT=/home/build_user
SHELL ["/bin/bash", "-c"]

WORKDIR $SOURCE_ROOT

ENV USER=build_user
RUN cd $SOURCE_ROOT \
&& wget $PATCH_URL/build_crdb.sh \
&& sed -i 's/\b\(bison\)\b//g' build_crdb.sh \
&& bash build_crdb.sh -y

# Build a fresh image without all the build requirements
FROM registry.access.redhat.com/ubi9/ubi:9.4-1214.1729773476

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ENV PATH=/usr/local/go/bin:/cockroach:$PATH

RUN dnf install sudo tzdata hostname tar wget cmake gcc-c++ keyutils-libs-devel -y \
    && mkdir -p /cockroach \
    && mkdir -p /usr/local/lib/cockroach \
    && mkdir -p /docker-entrypoint-initdb.d

RUN wget https://ftp.samba.org/pub/cwrap/resolv_wrapper-1.1.8.tar.gz \
&& tar zxf resolv_wrapper-1.1.8.tar.gz \
&& cd resolv_wrapper-1.1.8 && mkdir obj && cd obj \
&& cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
&& make \
&& sudo make install

RUN wget -O /cockroach/cockroach.sh https://raw.githubusercontent.com/cockroachdb/cockroach/refs/tags/v25.4.2/build/deploy/cockroach.sh

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
