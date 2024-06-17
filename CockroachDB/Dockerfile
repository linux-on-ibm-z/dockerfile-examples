# © Copyright IBM Corporation 2020, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 24.1.0 ####################################
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
ARG CRDB_VER=24.1.0
ARG BAZELLIB_VER=1.32.1
ARG GO_VER=1.22.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN apt-get update \
&& apt-get install -y sudo \
&& useradd -m build_user \
&& usermod -aG sudo build_user \
# disable sudo password
&& echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# CockroachDB dev script cannot be run by root user
USER build_user

# Set PATH
ENV SOURCE_DIR=/home/build_user
ENV PATH=$PATH:$SOURCE_DIR/dist/bazel/output/:$SOURCE_DIR/goroot/bin
ENV GOROOT_BOOTSTRAP=$SOURCE_DIR/go_bootstrap/go

WORKDIR $SOURCE_DIR

# Install following build dependencies
RUN sudo apt-get update \
&& sudo DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y autoconf automake wget make \
libssl-dev libncurses5-dev bison xz-utils patch g++ curl git python libresolv-wrapper tzdata libkeyutils-dev openjdk-11-jdk\
# Install CMake
&& cd $SOURCE_DIR \
&& wget https://github.com/Kitware/CMake/releases/download/v3.29.0/cmake-3.29.0.tar.gz \
&& tar -xzf cmake-3.29.0.tar.gz \
&& cd cmake-3.29.0 \
&& ./bootstrap \
&& make \
&& sudo make install \
# Install Go
&& cd $SOURCE_DIR \
&& mkdir go_bootstrap && cd go_bootstrap \
&& wget https://go.dev/dl/go${GO_VER}.linux-s390x.tar.gz \
&& tar -xzf go${GO_VER}.linux-s390x.tar.gz \
&& cd $SOURCE_DIR \
&& git clone -b go${GO_VER} https://go.googlesource.com/go goroot \
&& cd goroot \
&& wget -O $SOURCE_DIR/go.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/$CRDB_VER/patch/go.patch \
&& git apply --reject --whitespace=fix $SOURCE_DIR/go.patch \
&& cd src && ./make.bash \
# Install Bazel
&& cd $SOURCE_DIR \
&& wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/6.4.0/build_bazel.sh \
&& bash build_bazel.sh -y

ENV USER build_user
# Install Bazel-lib
RUN cd $SOURCE_DIR \
&& git clone https://github.com/aspect-build/bazel-lib.git \
&& cd bazel-lib && git checkout v$BAZELLIB_VER \
&& wget -O $SOURCE_DIR/bazel-lib.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/$CRDB_VER/patch/bazel-lib.patch \
&& git apply --reject --whitespace=fix $SOURCE_DIR/bazel-lib.patch \
&& bazel build @aspect_bazel_lib//tools/copy_directory \
&& bazel build @aspect_bazel_lib//tools/copy_to_directory \
# Download and Install CockroachDB
&& cd $SOURCE_DIR \
&& git clone https://github.com/cockroachdb/cockroach \
&& cd cockroach \
&& git checkout v$CRDB_VER \
&& wget -O $SOURCE_DIR/cockroachdb.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/$CRDB_VER/patch/crdb.patch \
&& sed -i "s#SOURCE_ROOT_PATH#${SOURCE_DIR}#g" $SOURCE_DIR/cockroachdb.patch \
&& git apply --reject --whitespace=fix $SOURCE_DIR/cockroachdb.patch \
&& sudo cp ${SOURCE_DIR}/bazel-lib/lib/private/copy_to_directory_toolchain.bzl . \
&& sudo cp ${SOURCE_DIR}/bazel-lib/lib/private/copy_directory_toolchain.bzl . \
&& echo 'build --remote_cache=http://127.0.0.1:9867' > ~/.bazelrc \
&& printf 'build --config=dev \nbuild --config nolintonbuild\n' >> .bazelrc.user \
&& echo "test --test_tmpdir=$SOURCE_DIR/cockroach/tmp" >> .bazelrc.user \
&& ./dev doctor \
&& ./dev build \
&& sudo cp cockroach /usr/local/bin

# Build a fresh image without all the build requirements
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH=/usr/local/go/bin:/cockroach:$PATH

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && apt-get install -y tzdata hostname tar wget \
libresolv-wrapper libkeyutils-dev \
    && mkdir -p /cockroach \
    && mkdir -p /usr/local/lib/cockroach \
    && mkdir -p /docker-entrypoint-initdb.d

RUN wget -O /cockroach/cockroach.sh https://raw.githubusercontent.com/cockroachdb/cockroach/v24.1.0/build/deploy/cockroach.sh

COPY --from=builder /usr/local/bin/cockroach  /cockroach/
RUN chmod +x /cockroach/cockroach.sh

WORKDIR /cockroach/

# Include the directory in the path to make it easier to invoke
# commands via Docker
ENV PATH=/cockroach:$PATH

# Expose ports
EXPOSE 26257 8080
ENTRYPOINT ["/cockroach/cockroach.sh"]
