# © Copyright IBM Corporation 2017, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Sysdig version 0.30.2 #########
#
# This Dockerfile builds a basic installation of Sysdig.
#
# Sysdig is open source, system-level exploration: capture system state and activity from a running Linux instance, then save, filter and analyze.
# Sysdig is scriptable in Lua and includes a command line interface and a powerful interactive UI, csysdig, that runs in your terminal.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To guarantee a smooth deployment, the kernel headers must be installed in the host operating system, before running sysdig.
#
# To run sysdig in a Docker container use below command
#  docker run -it --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v
#   /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:rw -v /usr:/host/usr:ro --name <container_name> <image_name>
#
# For more details, see https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux#installation-inside-a-docker-container
#
# The official website
# https://www.sysdig.org/
##################################################################################

# Base Image
FROM s390x/ubuntu:20.04 AS builder

ARG SYSDIG_VER=0.30.2

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y git g++ \
        linux-headers-$(uname -r) cmake libelf-dev pkg-config kmod
        
# Download source code
RUN cd $SOURCE_ROOT \
        && git clone https://github.com/draios/sysdig.git \
        && cd sysdig      \
        && git checkout ${SYSDIG_VER}  \
        && mkdir build \
# Configure Sysdig
        && cd build \
        && cmake -DCMAKE_INSTALL_PREFIX=/opt/sysdig -DSYSDIG_VERSION=${SYSDIG_VER} .. \
        && cd $SOURCE_ROOT/sysdig/build/falcosecurity-libs-repo/falcosecurity-libs-prefix/src/falcosecurity-libs/cmake/modules \
        && sed -i 's+https://github.com/curl/curl/releases/download/curl-7_84_0/curl-7.84.0.tar.bz2+https://github.com/curl/curl/releases/download/curl-7_85_0/curl-7.85.0.tar.bz2+g' curl.cmake \
        && sed -i 's/702fb26e73190a3bd77071aa146f507b9817cc4dfce218d2ab87f00cd3bc059d/21a7e83628ee96164ac2b36ff6bf99d467c7b0b621c1f7e317d8f0d96011539c/g' curl.cmake \
        && sed -i '135{h;d};136G' grpc.cmake \
# Build and Install Sysdig
        && cd $SOURCE_ROOT/sysdig/build \
        && make \
        && make install
# Clean up cache data and remove dependencies which are not required
RUN rm -rf $SOURCE_ROOT \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

FROM s390x/ubuntu:20.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        bc \
        binutils \
        clang-7 \
        curl \
        dkms \
        gnupg2 \
        ca-certificates \
        gcc \
        libc6-dev \
        libelf-dev \
        libelf1 \
        less \
        llvm-7 \
        procps \
        xz-utils \
        kmod \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/sysdig /opt/sysdig

RUN for b in /opt/sysdig/bin/*; do ln -s "$b" /usr/bin/$(basename "$b"); done \
    && for b in /opt/sysdig/src/*; do ln -s "$b" /usr/src/$(basename "$b"); done

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENV HOST_ROOT /host
ENV SYSDIG_HOST_ROOT /host
ENV HOME /root

# Some base images have an empty /lib/modules by default
# If it's not empty, docker build will fail instead of
# silently overwriting the existing directory
RUN rm -rf /lib/modules \
    && ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]
# End of Dockerfile
