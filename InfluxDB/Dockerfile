# © Copyright IBM Corporation 2020, 2025
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for InfluxDB 3.4.0 ############################s
#
# Builds InfluxDB
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Running the container
#
# The InfluxDB image exposes a shared volume under /var/lib/influxdb3, so you
# can mount a host directory to that point to access persisted container data.
# You can use the following command to start InfluxDB 3 Core:
#
# $ docker run --rm -p 8181:8181 \
#     -v $PWD/data:/var/lib/influxdb3/data \
#     -v $PWD/plugins:/var/lib/influxdb3/plugins \
#     <image_name> influxdb3 serve \
#       --node-id=my-node-0 \
#       --object-store=file \
#       --data-dir=/var/lib/influxdb3/data \
#       --plugin-dir=/var/lib/influxdb3/plugins

# After starting your InfluxDB 3 server, follow the Get Started guide at https://docs.influxdata.com/influxdb3/core/get-started/ to create an authorization token and start writing, querying, and processing data via the built-in influxdb3 CLI or the HTTP API.

# For more information, see https://hub.docker.com/_/influxdb
###############################################################################

# Base image
FROM ubuntu:24.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG INFLUXDB_VERSION=3.4.0
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/InfluxDB/${INFLUXDB_VERSION}/patch"

RUN mkdir /influxdb3
WORKDIR /influxdb3

ARG PROFILE=release
ARG PACKAGE=influxdb3
ARG PBS_DATE=20250818
ARG PBS_VERSION=3.13.7
ENV PROFILE=$PROFILE \
    PACKAGE=$PACKAGE

COPY fetch-python-standalone.bash /tmp/fetch-python-standalone.bash

######## Build and install InfluxDB3 ###########################################
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates binutils build-essential curl pkg-config \
        curl libssl-dev clang lld git patchelf \
        gettext-base protobuf-compiler zstd libz-dev \
        gnupg libprotobuf-dev \
        libssl3 && \
    rm -rf /var/lib/apt/lists* && \
    groupadd --gid 1500 influxdb3 && \
    useradd  --uid 1500 --gid influxdb3 --shell /bin/bash --create-home influxdb3 && \
    mkdir -p /var/lib/influxdb3 \
             /usr/lib/influxdb3 \
             /plugins && \
    chmod +x /tmp/fetch-python-standalone.bash && \
    /tmp/fetch-python-standalone.bash /influxdb3/python-artifacts "${PBS_DATE}" "${PBS_VERSION}" && \
    tar -C /influxdb3/python-artifacts -zxf /influxdb3/python-artifacts/all.tar.gz "./s390x-unknown-linux-gnu" && \
    sed -i 's#tmp/workspace#influxdb3#' "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" && \
    cat "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.88 && \
    . $HOME/.cargo/env && \
    git clone https://github.com/apache/arrow-rs.git && \
    cd arrow-rs && git checkout 55.2.0 && \
    curl -sSL ${PATCH_URL}/arrow.patch | patch -p1 || error "arrow.patch" && cd .. && \
    git clone --depth 1 -b v$INFLUXDB_VERSION https://github.com/influxdata/influxdb.git && \
    cd influxdb && curl -sSL ${PATCH_URL}/influxdb.patch | patch -p1 || error "influxdb.patch" && \
    sed -i "s|SOURCE_ROOT|/influxdb3|g" Cargo.toml && \
    PYO3_CONFIG_FILE="/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" cargo build --package="$PACKAGE" --profile="$PROFILE" && \
    objcopy --compress-debug-sections "target/$PROFILE/$PACKAGE" && \
    cp "target/$PROFILE/$PACKAGE" "/usr/bin/$PACKAGE" && \
    patchelf --set-rpath '$ORIGIN/python/lib:$ORIGIN/../lib/influxdb3/python/lib' "/usr/bin/$PACKAGE" && \
    cp -a "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/python" /usr/lib/influxdb3/python && \
    chown -R influxdb3:influxdb3 /var/lib/influxdb3 /plugins && \
    chown -R root:root /usr/lib/influxdb3 && \
    # Cleanup \
    cd .. && rm -rf arrow-rs influxdb python-artifacts && \
    . $HOME/.cargo/env && rustup self uninstall -y && \
    apt-get purge -y \
      binutils build-essential pkg-config \
      libssl-dev clang lld git patchelf \
      protobuf-compiler zstd libz-dev \
      gnupg libprotobuf-dev && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* \
              /usr/include/* \
              /usr/share/doc/* \
              /usr/share/man/* \
              /tmp/* \
              /root/.cargo \
              /root/.rustup

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER influxdb3
RUN mkdir ~/.influxdb3

ENV INFLUXDB3_PLUGIN_DIR=/plugins
ENV INFLUXDB3_DATA_DIR=/home/influxdb3/.influxdb3
ENV INFLUXDB_IOX_DB_DIR=/var/lib/influxdb3
ENV LOG_FILTER=info

EXPOSE 8181

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["influxdb3", "serve"]
