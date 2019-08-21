# © Copyright IBM Corporation 2018, 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################################### Dockerfile for GlusterFS version 6.1 ##########################################
#
# This Dockerfile builds a basic installation of GlusterFS.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start GlusterFS container using the below command
# docker run --name <container_name> --privileged=true -d <image_name>
#
###########################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

ARG GLUSTERFS_VER=6.3

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set Environment Variables
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" SOURCE_DIR="/tmp/"

WORKDIR $SOURCE_DIR

# Install Dependencies
RUN apt-get update && apt-get install -y  \
    autoconf \
    automake \
    bison \
    flex \
    gcc \
    git \
    libacl1-dev \
    libaio-dev \
    libfuse-dev \
    libglib2.0-dev \
    libibverbs-dev \
    librdmacm-dev \
    libreadline-dev \
    libssl-dev \
    libtool \
    liburcu-dev \
    libxml2-dev \
    lvm2 \
    make \
    openssl \
    pkg-config \
    python3 \
    uuid-dev \
    zlib1g-dev \

# Build GlusterFS from source
 && git clone https://github.com/gluster/glusterfs -b v$GLUSTERFS_VER \
 && cd glusterfs \
 && ./autogen.sh \
 && ./configure --enable-gnfs \
 && sed -i '37d' xlators/performance/io-threads/src/io-threads.h \
 && sed -i '37i #define IOT_THREAD_STACK_SIZE   ((size_t)(512*1024))' xlators/performance/io-threads/src/io-threads.h \
 && make \
 && make install \
 && ldconfig \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
   make \
   automake \
   autoconf \
   wget \
   git \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/glusterfs \

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

# Start the Gluster daemon
ENTRYPOINT /usr/local/sbin/glusterd && tail -f /dev/null

# End of Dockerfile
