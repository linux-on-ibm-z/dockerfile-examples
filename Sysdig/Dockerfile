# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Sysdig version 0.41.4 #########
#
# This Dockerfile builds a basic installation of Sysdig.
#
# Sysdig is open source, system-level exploration: capture system state and activity from a running Linux instance, then save, filter and analyze.
# Sysdig is scriptable in Lua and includes a command line interface and a powerful interactive UI, csysdig, that runs in your terminal.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <IMAGE_NAME> .
#
# To guarantee a smooth deployment, the kernel headers must be installed in the host operating system, before running sysdig.
#
# To run sysdig in a Docker container use below command
# "docker run --rm -i -t --privileged --net=host -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v 
# /boot:/host/boot:ro -v /src:/src -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro -v /etc:/host/etc:ro --name <NAME> <IMAGE-NAME>"
# For more details, see https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux#installation-inside-a-docker-container
#
# The official website
# https://www.sysdig.org/
##################################################################################

# Base Image
FROM s390x/ubuntu:24.04 AS builder

ARG SYSDIG_VER=0.41.4
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Sysdig/${SYSDIG_VER}/patch"

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y git g++ g++-11 \
        linux-headers-generic clang llvm cmake libelf-dev pkg-config kmod rpm libssl-dev wget \
        && mkdir -p /lib/modules/$(uname -r) \
        && version=$(ls /usr/src/ | grep generic | tail -1) \
        && ln -s /usr/src/$version /lib/modules/$(uname -r)/build \
        && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11 \
        && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11 \
# Install bpftool
        && cd $SOURCE_ROOT \
        && git clone --recurse-submodules https://github.com/libbpf/bpftool.git \
        && cd bpftool && cd src \
        && make \
        && make install \
# Install go
        && cd $SOURCE_ROOT \
        && wget -q https://go.dev/dl/go1.25.0.linux-s390x.tar.gz \
        && chmod ugo+r go1.25.0.linux-s390x.tar.gz \
        && tar -C /usr/local -xzf go1.25.0.linux-s390x.tar.gz \
        && ln -sf /usr/local/go/bin/go /usr/bin/ \
        && ln -sf /usr/local/go/bin/gofmt /usr/bin/ \
        && export GOPATH=$SOURCE_ROOT \
        && export PATH=$GOPATH/bin:$PATH \
        && export CC=$(which gcc) \
        && export CXX=$(which g++) \
# Build container_plugin
        && cd $SOURCE_ROOT \
        && git clone --depth 1 -b plugins/container/v0.6.0 https://github.com/falcosecurity/plugins.git \
        && cd plugins/plugins/container \
        && make libcontainer.so \
        && tar zcf $SOURCE_ROOT/container-0.6.0-linux-s390x.tar.gz libcontainer.so \
# Download source code and apply patch
        && cd $SOURCE_ROOT \
        && wget -O $SOURCE_ROOT/container_plugin_cmake.patch $PATCH_URL/container_plugin_cmake.patch \
        && git clone -b ${SYSDIG_VER} https://github.com/draios/sysdig.git \
        && cd sysdig \
        && sed -i "s#SOURCE_ROOT_PATH#$SOURCE_ROOT#g" $SOURCE_ROOT/container_plugin_cmake.patch \
        && git apply $SOURCE_ROOT/container_plugin_cmake.patch \
        && mkdir build \
# Configure Sysdig
        && cd build \
        && cmake -Wno-dev -DBUILD_DRIVER=OFF -DSYSDIG_VERSION=${SYSDIG_VER} .. \
# Build and Install Sysdig
        && cd $SOURCE_ROOT/sysdig/build \
        && make -j $(nproc) \
        && make install \
        && cmake --build . --target package --config Release


FROM s390x/ubuntu:24.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG BUILD_VERSION=0.41.4
ENV BUILD_VERSION=${BUILD_VERSION}

ENV HOST_ROOT=/host
ENV HOME=/root

COPY --from=builder /tmp/source/sysdig/build/sysdig-${BUILD_VERSION}-*.deb /

RUN apt-get update && apt-get install -y dkms libelf-dev curl \
    && dpkg -i /sysdig-${BUILD_VERSION}-$(uname -p).deb && rm /sysdig-*.deb \
    && rm -rf /lib/modules \
    && ln -s $HOST_ROOT/lib/modules /lib/modules

COPY ./docker-entrypoint.sh /

RUN ["chmod", "+x", "/docker-entrypoint.sh"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]
# End of Dockerfile
