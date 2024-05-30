# © Copyright IBM Corporation 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Envoy version 1.29.2 #########
#
# This Dockerfile builds a basic installation of Envoy.
#
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t envoy:v1.29.2 .
#
# To start container from image & start an application in production mode
# docker run -d --name envoy -p 9901:9901 -p 10000:10000 envoy:v1.29.2
# Reference:
# https://github.com/envoyproxy/envoy
# https://www.envoyproxy.io/docs/envoy/v1.29.2/start/docker
#
##################################################################################
FROM s390x/ubuntu:22.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV SOURCE_ROOT=/tmp/source
ENV PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Envoy/1.29.2/patch
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
    sudo \
    curl \
    libtool \
    patch \
    python3-pip \
    unzip \
    virtualenv \
    pkg-config \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    locales \
    zip \
    unzip \
    libssl-dev \
    git \
# Install Clang 14
    && cd "$SOURCE_ROOT" \
    && wget https://apt.llvm.org/llvm.sh \
    && sed -i 's,add-apt-repository "${REPO_NAME}",add-apt-repository "${REPO_NAME}" -y,g' llvm.sh \
    && sudo chmod +x llvm.sh \
    && sudo ./llvm.sh 14 \
    && sudo rm ./llvm.sh \
# Install JDK
    && sudo apt-get install -y openjdk-11-jdk \
    && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    && export PATH=$JAVA_HOME/bin:$PATH \
# Build bazel
    && cd "$SOURCE_ROOT" \
    && mkdir bazel && cd bazel \
    && wget https://github.com/bazelbuild/bazel/releases/download/6.3.2/bazel-6.3.2-dist.zip \
    && unzip -q bazel-6.3.2-dist.zip \
    && chmod -R +w . \
    && curl -sSL https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/6.3.2/patch/bazel.patch | patch -p1 \
    && bash ./compile.sh \
    && export PATH=$PATH:${SOURCE_ROOT}/bazel/output/ \
# Install GCC 12 from repo
    && sudo apt-get install -y gcc-12 g++-12 \
    && sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 12 \
    && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 \
    && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12 \
    && sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 12 \
# Install Golang
    && cd "$SOURCE_ROOT" \
    && wget https://storage.googleapis.com/golang/go1.21.6.linux-s390x.tar.gz \
    && sudo tar -C /usr/local -xzf go1.21.6.linux-s390x.tar.gz \
    && export PATH=/usr/local/go/bin:$PATH \
    && export GOROOT=/usr/local/go \
    && export GOPATH=$SOURCE_ROOT/go/bin \
# C/C++ environment settings
    && sudo locale-gen en_US.UTF-8 \
    && export LC_ALL=C \
    && unset LANGUAGE \
    && export CC=clang-14 \
    && export CXX=clang++-14 \
    && sudo ln -sf /usr/bin/clang-14 /usr/bin/clang \
    && sudo ln -sf /usr/bin/clang++-14 /usr/bin/clang++ \
#Building Buildozer and Buildifier
    && cd "$SOURCE_ROOT"/ \
    && export PATH=$PATH:${SOURCE_ROOT}/bazel/output/ \
    && git clone -b v6.3.2 https://github.com/bazelbuild/buildtools.git \
    #Build buildifer
    && cd "$SOURCE_ROOT"/buildtools/buildifier \
    && bazel build //buildifier \
    && export BUILDIFIER_BIN=$GOPATH/bin/buildifier \
    #Build buildozer
    && cd "$SOURCE_ROOT"/buildtools/buildozer \
    && bazel build //buildozer \
    && export BUILDOZER_BIN=$GOPATH/bin/buildozer \
    && mkdir -p $SOURCE_ROOT/patch/ \
    && cd "$SOURCE_ROOT"/ \
    && rm -rf rules_foreign_cc \
    && git clone -b 0.10.1 https://github.com/bazelbuild/rules_foreign_cc.git \
    && cd rules_foreign_cc/ \
    && pwd \
    && ls -la \
    && curl -sSL ${PATCH_URL}/rules_foreign_cc.patch |  git apply - \
    && cd toolchains/ \
    && wget -O pkgconfig-valgrind.patch ${PATCH_URL}/pkgconfig-valgrind.patch \
# Build Envoy
    && cd "$SOURCE_ROOT"/ \
    && export PATH=$PATH:${SOURCE_ROOT}/bazel/output/ \
    && rm -rf envoy \
    && git clone --depth 1 -b v1.29.2 https://github.com/envoyproxy/envoy.git \
    && cd envoy \
# Apply patches-
    && curl -sSL ${PATCH_URL}/envoy_patch.diff | git apply - \
# Apply patch to update certificates-
    && curl -sSL https://github.com/phlax/envoy/commit/c84d38dbc13982c899b9bedc290525938c92fd16.patch | git apply - \
#Move patch files to envoy/bazel which will be applied to external packages while building envoy
    && cd $SOURCE_ROOT/envoy/bazel/ \
    && wget -O $SOURCE_ROOT/envoy/bazel/boringssl-s390x.patch ${PATCH_URL}/boringssl-s390x.patch \
    && wget -O $SOURCE_ROOT/envoy/bazel/cel-cpp-memory.patch ${PATCH_URL}/cel-cpp-memory.patch \
    && wget -O $SOURCE_ROOT/envoy/bazel/grpc-s390x.patch ${PATCH_URL}/grpc-s390x.patch \
    && wget -O $SOURCE_ROOT/envoy/bazel/foreign_cc/luajit-s390x.patch ${PATCH_URL}/luajit-s390x.patch \
    && wget -O $SOURCE_ROOT/envoy/bazel/quiche-s390x.patch ${PATCH_URL}/quiche-s390x.patch \
    && cd $SOURCE_ROOT/envoy/ \
    # Build envoy
    && bazel build envoy -c opt --override_repository=rules_foreign_cc=${SOURCE_ROOT}/rules_foreign_cc --config=clang \
    && cd $SOURCE_ROOT/envoy/ \
    && export PATH=$PATH:${SOURCE_ROOT}/bazel/output/ \
    # Build su-exec
    && bazel build external:su-exec -c opt --override_repository=rules_foreign_cc=${SOURCE_ROOT}/rules_foreign_cc --config=clang
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
  && apt-get -qq install --no-install-recommends -y ca-certificates \
  && apt-get -qq autoremove -y \
  && mkdir -p /usr/local/bin
COPY --from=builder $SOURCE_ROOT/envoy/bazel-bin/source/exe/envoy-static /usr/local/bin/envoy
