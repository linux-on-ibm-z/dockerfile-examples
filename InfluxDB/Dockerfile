# © Copyright IBM Corporation 2020, 2026
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for InfluxDB 3.10.0 ############################s
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

# Stage 1: Build WASM ELF
FROM ubuntu:24.04 AS wasm-builder
WORKDIR /tmp
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential pkg-config libssl-dev clang curl git \
        protobuf-compiler python3 python3-dev python3-pip python3-venv \
        libprotobuf-dev cmake lld ninja-build unzip && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    git clone --recursive -b wasi-sdk-24 --depth 1 https://github.com/webassembly/wasi-sdk && \
    cd wasi-sdk && \
    sed -i '22i #include <cstdint>' src/llvm-project/llvm/include/llvm/ADT/SmallVector.h && \
    cmake -G Ninja -B build/toolchain -S . \
    -DWASI_SDK_BUILD_TOOLCHAIN=ON \
    -DCMAKE_INSTALL_PREFIX=build/install && \
    cmake --build build/toolchain --target install && \
    cmake --build build/toolchain --target dist && \
    #build sysroot
    cmake -G Ninja -B build/sysroot -S . \
    -DCMAKE_INSTALL_PREFIX=build/install \
    -DCMAKE_TOOLCHAIN_FILE=build/install/share/cmake/wasi-sdk.cmake \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON && \
    cmake --build build/sysroot --target install && \
    cmake --build build/sysroot --target dist && \
    mkdir dist-my-platform && \
    cp build/toolchain/dist/* build/sysroot/dist/* dist-my-platform && \
    ./ci/merge-artifacts.sh && \
    cd /tmp && \
    rustup target add wasm32-wasip2 && \
    cargo install --locked cargo-deny && \
    cargo install --locked just && \
    curl -LsSf https://astral.sh/uv/0.9.30/install.sh | sh && \
    . $HOME/.local/bin/env && \
    cd /tmp && \
    git clone https://github.com/tombi-toml/tombi.git && \
    cd tombi && \
    cargo build --release && \
    uvx tombi --version && \
    cargo install --locked typos-cli && \
    cargo install --locked wasm-tools && \
    cd /tmp && \
    git clone https://github.com/influxdata/datafusion-udf-wasm && \
    cd datafusion-udf-wasm && \
    git checkout -b for-influxdb 89ab4ae6312c3a44859ddd43d9df4d4300d3086a && \
    export WASI_SDK_LOCAL_TARBALL="/tmp/wasi-sdk/build/sysroot/dist/wasi-sysroot-24.0.tar.gz" && \
    just guests::python::build-release && \
    mkdir -p out && \
    cargo run --bin=compile --features="all-arch" --release -- \
    target/wasm32-wasip2/release/datafusion_udf_wasm_python.wasm \
    out/datafusion_udf_wasm_python.release.s390x-unknown-linux-gnu.elf \
    s390x-unknown-linux-gnu && \
    cp out/datafusion_udf_wasm_python.release.s390x-unknown-linux-gnu.elf /tmp && \
    rm -rf /tmp/wasi-sdk /tmp/tombi /tmp/datafusion-udf-wasm


# Stage 2: Build InfluxDB binary
FROM ubuntu:24.04 AS influxdb-builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ARG INFLUXDB_VERSION=3.10.0
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/InfluxDB/${INFLUXDB_VERSION}/patch"

RUN mkdir /influxdb3
WORKDIR /influxdb3

ARG PROFILE=release
ARG PACKAGE=influxdb3
ARG PBS_DATE=20260610
ARG PBS_VERSION=3.13.14
ENV PROFILE=$PROFILE \
    PACKAGE=$PACKAGE

COPY fetch-python-standalone.bash /tmp/fetch-python-standalone.bash
COPY --from=wasm-builder /tmp/datafusion_udf_wasm_python.release.s390x-unknown-linux-gnu.elf /tmp/

######## Build and install InfluxDB3 ###########################################
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates binutils build-essential curl pkg-config \
        curl libssl-dev clang lld git patchelf \
        gettext-base protobuf-compiler zstd libz-dev \
        gnupg libprotobuf-dev \
        libssl3 && \
    rm -rf /var/lib/apt/lists* && \
    chmod +x /tmp/fetch-python-standalone.bash && \
    /tmp/fetch-python-standalone.bash /influxdb3/python-artifacts "${PBS_DATE}" "${PBS_VERSION}" && \
    tar -C /influxdb3/python-artifacts -zxf /influxdb3/python-artifacts/all.tar.gz "./s390x-unknown-linux-gnu" && \
    sed -i 's#tmp/workspace#influxdb3#' "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" && \
    cat "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.88 && \
    . $HOME/.cargo/env && \
    git clone --depth 1 -b 57.3.0 https://github.com/apache/arrow-rs.git && \
    cd arrow-rs && \
    curl -sSL ${PATCH_URL}/arrow.patch | git apply || error "arrow.patch" && cd .. && \
    git clone --depth 1 -b v$INFLUXDB_VERSION https://github.com/influxdata/influxdb.git && \
    cd influxdb && curl -sSL ${PATCH_URL}/influxdb.patch | git apply || error "influxdb.patch" && \
    sed -i "s|SOURCE_ROOT|/influxdb3|g" Cargo.toml && \
    sed -i "s|SOURCE_ROOT|/influxdb3|g" core/iox_query_udf/build.rs && \
    export IOX_QUERY_UDF_PYTHON_WASM="/tmp/datafusion_udf_wasm_python.release.s390x-unknown-linux-gnu.elf" && \
    PYO3_CONFIG_FILE="/influxdb3/python-artifacts/s390x-unknown-linux-gnu/pyo3_config_file.txt" cargo build --package="$PACKAGE" --profile="$PROFILE" && \
    objcopy --compress-debug-sections "target/$PROFILE/$PACKAGE" && \
    patchelf --set-rpath '$ORIGIN/python/lib:$ORIGIN/../lib/influxdb3/python/lib' "target/$PROFILE/$PACKAGE" && \
    #Preserve binary for next stage
    mkdir -p /artifacts/influxdb3 && \
    cp "target/$PROFILE/$PACKAGE" /artifacts/influxdb3 && \
    cp -a "/influxdb3/python-artifacts/s390x-unknown-linux-gnu/python" /artifacts/influxdb3 && \
    # Cleanup build artifacts
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

# Stage 3: Final runtime image
FROM ubuntu:24.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        gettext-base \
        gnupg \
        libssl3 && \
    rm -rf /var/lib/apt/lists*

ENV INFLUXDB_VERSION=3.10.0
# Install from previous build stage
COPY --from=influxdb-builder /artifacts/influxdb3/influxdb3 /usr/bin/influxdb3
COPY --from=influxdb-builder /artifacts/influxdb3/python /usr/lib/influxdb3/python

RUN groupadd --gid 1500 influxdb3 && \
    useradd  --uid 1500 --gid influxdb3 --shell /bin/bash --create-home influxdb3 && \
    mkdir -p /var/lib/influxdb3 \
             /usr/lib/influxdb3 \
             /plugins && \
    chown -R influxdb3:influxdb3 /var/lib/influxdb3 /plugins && \
    chown -R root:root /usr/lib/influxdb3

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER influxdb3
RUN mkdir ~/.influxdb3

ENV INFLUXDB3_PLUGIN_DIR=/plugins
ENV INFLUXDB3_DATA_DIR=/home/influxdb3/.influxdb3
ENV INFLUXDB3_SERVE_INVOCATION_METHOD=docker-hub
ENV INFLUXDB_IOX_DB_DIR=/var/lib/influxdb3
ENV LOG_FILTER=info

EXPOSE 8181

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["influxdb3", "serve"]