# © Copyright IBM Corporation 2024, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Envoy version 1.34.0 #########
#
# This Dockerfile builds a basic installation of Envoy.
#
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t envoy:v1.34.0 .
#
# To start container from image & start an application in production mode
# docker run -d --name envoy -p 9901:9901 -p 10000:10000 envoy:v1.34.0
# Reference:
# https://github.com/envoyproxy/envoy
# https://www.envoyproxy.io/docs/envoy/v1.34.0/start/docker
#
##################################################################################
FROM s390x/ubuntu:22.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV SOURCE_ROOT=/tmp/source
ENV PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Envoy/1.34.0/patch
ENV PREFIX=/usr/local

RUN  apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y sudo \
     && sudo useradd -s /bin/bash -d /home/nonroot/ -m -G sudo nonroot \
     && echo "nonroot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
     && mkdir -p $SOURCE_ROOT \
     && chown -R nonroot:nonroot $SOURCE_ROOT \
     && sudo chmod -R 755 $SOURCE_ROOT

USER nonroot

RUN sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
    autoconf \
    curl \
    git \
    libtool \
    patch \
    python3-pip \
    virtualenv \
    pkg-config \
    gcc \
    g++ \
    locales \
    build-essential \
    openjdk-21-jdk \
    python2 \
    python2-dev \
    python-is-python3 \
    python3 \
    python3-dev \
    zip \
    unzip \
    libssl-dev \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    gcc-12 \
    g++-12 \
# Install Clang 14
    && cd "$SOURCE_ROOT" \
    && wget https://apt.llvm.org/llvm.sh \
    && sudo chmod +x llvm.sh \
    && sudo ./llvm.sh 14 \
    && sudo rm ./llvm.sh \
# Setup JDK
    && export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-s390x \
    && export PATH=$JAVA_HOME/bin:$PATH \
# Setup GCC 12
    && sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 12 \
    && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 \
    && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12 \
    && sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 12 \
# Install Rust
    && cd "$SOURCE_ROOT" \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh /dev/stdin -y \
    && export PATH=$HOME/.cargo/bin:$PATH \
# Install Golang
    && cd "$SOURCE_ROOT" \
    && wget https://storage.googleapis.com/golang/go1.24.2.linux-s390x.tar.gz \
    && sudo tar -C /usr/local -xzf go1.24.2.linux-s390x.tar.gz \
    && export PATH=/usr/local/go/bin:$PATH \
    && export GOROOT=/usr/local/go \
    && export GOPATH=$SOURCE_ROOT/go/bin \
# Build bazel
    && cd "$SOURCE_ROOT" \
    && mkdir bazel && cd bazel \
    && wget https://github.com/bazelbuild/bazel/releases/download/7.6.0/bazel-7.6.0-dist.zip \
    && unzip -q bazel-7.6.0-dist.zip \
    && chmod -R +w . \
    && env EXTRA_BAZEL_ARGS="--tool_java_runtime_version=local_jdk" bash ./compile.sh \
    && sudo cp output/bazel /usr/local/bin/ \
# Build rules_rust cargo bazel
    && cd "$SOURCE_ROOT" \
    && git clone -b "0.56.0" --depth 1 https://github.com/bazelbuild/rules_rust.git \
    && cd rules_rust/crate_universe/ \
    && cargo build --release --locked --bin cargo-bazel \
    && cp target/release/cargo-bazel "$SOURCE_ROOT"/ \
# Build rules_buf
    && cd "$SOURCE_ROOT" \
    && export BUF_VERSION="1.50.0" \
    && export BUF_DIR="${SOURCE_ROOT}/rules_buf/local" \
    && mkdir -p "$BUF_DIR" \
    && git clone -b "v$BUF_VERSION" --depth 1 https://github.com/bufbuild/buf.git \
    && cd buf \
    && GOBIN="$BUF_DIR" go install "github.com/bufbuild/buf/cmd/buf@v${BUF_VERSION}" \
    && mv "$BUF_DIR/buf" "$BUF_DIR/buf-Linux-s390x" \
    && GOBIN="$BUF_DIR" go install "github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking@v${BUF_VERSION}" \
    && mv "$BUF_DIR/protoc-gen-buf-breaking" "$BUF_DIR/protoc-gen-buf-breaking-Linux-s390x" \
    && GOBIN="$BUF_DIR" go install "github.com/bufbuild/buf/cmd/protoc-gen-buf-lint@v${BUF_VERSION}" \
    && mv "$BUF_DIR/protoc-gen-buf-lint" "$BUF_DIR/protoc-gen-buf-lint-Linux-s390x" \
    && cd "$BUF_DIR" \
    && sha256sum buf-Linux-s390x protoc-gen-buf-breaking-Linux-s390x protoc-gen-buf-lint-Linux-s390x > sha256.txt \
# Get Envoy source
    && cd "$SOURCE_ROOT"/ \
    && export PATH=$PATH:${SOURCE_ROOT}/bazel/output/ \
    && rm -rf envoy \
    && git clone --depth 1 -b v1.34.0 https://github.com/envoyproxy/envoy.git \
    && cd envoy \
    && ./bazel/setup_clang.sh "/usr/lib/llvm-14" \
    && echo "build --repo_env=CARGO_BAZEL_GENERATOR_URL=file:${SOURCE_ROOT}/cargo-bazel" >> user.bazelrc \
    && echo "build --repo_env=BUFBUILD_BUF_TOOLCHAIN_URL=file:${SOURCE_ROOT}/rules_buf" >> user.bazelrc \
# Apply patches
    && curl -sSL $PATCH_URL/envoy-build.patch | git apply - \
    && curl -sSL $PATCH_URL/envoy-test.patch | git apply - \
    && curl -sSL $PATCH_URL/boringssl-s390x.patch > $SOURCE_ROOT/envoy/bazel/boringssl-s390x.patch \
    && curl -sSL $PATCH_URL/quiche-s390x.patch > $SOURCE_ROOT/envoy/bazel/external/quiche-s390x.patch \
    && curl -sSL $PATCH_URL/proxy_wasm_cpp_host-s390x.patch > $SOURCE_ROOT/envoy/bazel/proxy_wasm_cpp_host-s390x.patch \
    && curl -sSL $PATCH_URL/rules_foreign_cc-s390x.patch > $SOURCE_ROOT/envoy/bazel/rules_foreign_cc-s390x.patch \
    && curl -sSL https://github.com/iii-i/moonjit/commit/dee73f516f0da49e930dcfa1dd61720dcb69b7dd.patch > $SOURCE_ROOT/envoy/bazel/foreign_cc/luajit-s390x.patch \
    && curl -sSL https://github.com/iii-i/moonjit/commit/035f133798adb856391928600f7cb6b4f81578ab.patch >> $SOURCE_ROOT/envoy/bazel/foreign_cc/luajit-s390x.patch \
    && curl -sSL $PATCH_URL/luajit-as.patch > $SOURCE_ROOT/envoy/bazel/foreign_cc/luajit-as.patch \
    && curl -sSL $PATCH_URL/rules_buf-s390x.patch > $SOURCE_ROOT/envoy/api/bazel/rules_buf-s390x.patch \
    && curl -sSL $PATCH_URL/grpc-s390x.patch > $SOURCE_ROOT/envoy/bazel/grpc-s390x.patch \
# Build envoy
    && bazel build envoy.stripped -c opt --config=clang \
    && cd $SOURCE_ROOT/envoy/ \
# Build su-exec
    && bazel build @com_github_ncopa_suexec//:su-exec -c opt --config=clang

FROM s390x/ubuntu:22.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV SOURCE_ROOT=/tmp/source
ENV DEBIAN_FRONTEND=noninteractive
#Expose the port for envoy
EXPOSE 10000
# Copy su-exec binary
COPY --from=builder $SOURCE_ROOT/envoy/bazel-bin/external/com_github_ncopa_suexec/su-exec /usr/local/bin/su-exec
# Copy docker-entrypoint.sh
COPY --from=builder $SOURCE_ROOT/envoy/ci/docker-entrypoint.sh /
# Copy envoy.yaml
COPY --from=builder $SOURCE_ROOT/envoy/configs/envoyproxy_io_proxy.yaml /etc/envoy/envoy.yaml
CMD ["envoy", "-c", "/etc/envoy/envoy.yaml"]
RUN mkdir -p /etc/envoy \
    && adduser --group --system envoy
ENTRYPOINT ["/docker-entrypoint.sh"]
RUN --mount=type=tmpfs,target=/var/cache/apt \
  --mount=type=tmpfs,target=/var/lib/apt/lists \
  apt-get -qq update \
  && apt-get -qq upgrade -y \
  && apt-get -qq install --no-install-recommends -y ca-certificates libatomic1 \
  && apt-get -qq autoremove -y \
  && mkdir -p /usr/local/bin
COPY --from=builder $SOURCE_ROOT/envoy/bazel-bin/source/exe/envoy-static.stripped /usr/local/bin/envoy
