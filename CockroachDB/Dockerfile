# © Copyright IBM Corporation 2020, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for CockroachDB version 22.2.7 ####################################
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
ARG CRDB_VER=22.2.7

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
ENV PATH=$PATH:$SOURCE_DIR/dist/bazel/output/

WORKDIR $SOURCE_DIR

# Install following build dependencies
RUN sudo apt-get update \
&& sudo DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y autoconf automake wget make \
libssl-dev libncurses5-dev bison xz-utils patch g++ curl git python libresolv-wrapper tzdata libkeyutils-dev \
# Install CMake
&& cd $SOURCE_DIR \
&& wget https://github.com/Kitware/CMake/releases/download/v3.23.3/cmake-3.23.3.tar.gz \
&& tar -xzf cmake-3.23.3.tar.gz \
&& cd cmake-3.23.3 \
&& ./bootstrap \
&& make \
&& sudo make install \
# Install Bazel
&& cd $SOURCE_DIR \
&& wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/5.1.1/build_bazel.sh \
&& bash build_bazel.sh -y \
# Download and Install CockroachDB
&& cd $SOURCE_DIR \
&& git clone https://github.com/cockroachdb/cockroach \
&& cd cockroach \
&& git checkout v$CRDB_VER \
&& git submodule update --init --recursive \
&& wget -O $SOURCE_DIR/cockroachdb.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CockroachDB/$CRDB_VER/patch/crdb.patch \
&& git apply --reject --whitespace=fix $SOURCE_DIR/cockroachdb.patch \
&& cd $SOURCE_DIR/cockroach \
&& echo 'build --remote_cache=http://127.0.0.1:9867' > ~/.bazelrc \
&& printf 'build --config=dev \nbuild --config nolintonbuild\n' >> .bazelrc.user \
&& echo "test --test_tmpdir=$SOURCE_DIR/cockroach/tmp" >> .bazelrc.user \
&& ./dev doctor \
&& ./dev build \
&& sudo cp cockroach /usr/local/bin \
&& bazel build c-deps:libgeos --config force_build_cdeps \
&& sudo mkdir -p /usr/local/lib/cockroach \
&& sudo cp _bazel/bin/c-deps/libgeos_foreign/lib/libgeos.so /usr/local/lib/cockroach/ \
&& sudo cp _bazel/bin/c-deps/libgeos_foreign/lib/libgeos_c.so /usr/local/lib/cockroach/

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

RUN wget -O /cockroach/cockroach.sh https://raw.githubusercontent.com/cockroachdb/cockroach/v22.2.7/build/deploy/cockroach.sh

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
