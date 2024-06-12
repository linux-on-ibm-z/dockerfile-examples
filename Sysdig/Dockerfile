# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Sysdig version 0.36.1 #########
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
#
# For more details, see https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux#installation-inside-a-docker-container
#
# The official website
# https://www.sysdig.org/
##################################################################################

# Base Image
FROM s390x/ubuntu:22.04 AS builder

ARG SYSDIG_VER=0.36.1

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y git g++ \
        linux-headers-generic cmake libelf-dev pkg-config kmod rpm \
	&& mkdir -p /lib/modules/$(uname -r) \
        && version=$(ls /usr/src/ | grep generic | tail -1) \
        && ln -s /usr/src/$version /lib/modules/$(uname -r)/build \
# Download source code
	&& cd $SOURCE_ROOT \
        && git clone https://github.com/draios/sysdig.git \
        && cd sysdig      \
        && git checkout ${SYSDIG_VER}  \
        && mkdir build \
# Configure Sysdig
        && cd build \
        && cmake -Wno-dev -DBUILD_DRIVER=OFF -DSYSDIG_VERSION=${SYSDIG_VER} .. \
# Build and Install Sysdig
        && cd $SOURCE_ROOT/sysdig/build \
	&& sed -i 's,c-ares.haxx.se/download/,github.com/c-ares/c-ares/releases/download/cares-1_19_1/,g' ./c-ares-prefix/src/c-ares-stamp/download-c-ares.cmake \
    	&& sed -i 's,c-ares.haxx.se/download/,github.com/c-ares/c-ares/releases/download/cares-1_19_1/,g' ./falcosecurity-libs-repo/falcosecurity-libs-prefix/src/falcosecurity-libs/cmake/modules/cares.cmake \
        && make -j $(nproc) \
        && make install \
        && cmake --build . --target package --config Release


FROM s390x/ubuntu:22.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG BUILD_VERSION=0.36.1
ENV BUILD_VERSION=${BUILD_VERSION}

ENV SYSDIG_HOST_ROOT /host

COPY --from=builder /tmp/source/sysdig/build/sysdig-${BUILD_VERSION}-*.deb /

RUN apt-get update && apt-get install -y dkms libelf-dev curl \
    && dpkg -i /sysdig-${BUILD_VERSION}-$(uname -p).deb && rm /sysdig-*.deb \
    && rm -rf /lib/modules \
    && ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

COPY ./docker-entrypoint.sh /

RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]
# End of Dockerfile
