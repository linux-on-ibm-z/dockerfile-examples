################# Dockerfile for MongoDB version v3.3.12 ###########################
#
# This Dockerfile builds a basic installation of MongoDB.
#
# MongoDB is an open source database that uses a document-oriented data model.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a container of MongoDB image, use following command:
# docker run --name <container name> -p <port no>:27017 -d <image name>
#
####################################################################################
# Base Image
FROM  s390x/ubuntu:16.04

# The Author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    binutils \
    binutils-dev \
    build-essential \
    bzip2 \
    flex \
    g++ \
    gcc \
    git \
    glibc-source \
    golang \
    libssl-dev \
    make \
    scons \
    subversion \
    tar \
    texinfo \
    wget \
    zlib1g-dev \
 && cd $SOURCE_DIR && git clone https://github.com/gcc-mirror/gcc \
 && cd gcc && git checkout gcc-5_3_0-release \
 && ./contrib/download_prerequisites \
 && ./configure --prefix="/opt/gcc"  --enable-shared --with-system-zlib --enable-threads=posix --enable-__cxa_atexit --enable-checking --enable-gnu-indirect-function --enable-languages="c,c++" --disable-bootstrap --disable-multilib \
 && make && make install \
 && ln -sf /opt/gcc/bin/gcc /usr/bin/gcc \
 && ln -sf /opt/gcc/bin/g++ /usr/bin/g++ \

# Build mongodb server
 && cd $SOURCE_DIR && git clone https://github.com/mongodb/mongo \
 && cd mongo && git checkout r3.3.12 \
 && scons --opt --allocator=system all --use-s390x-crc32=off \
 && chmod -c 777 * \
 && cp $SOURCE_DIR/mongo/mongo /usr/bin \
 && cp $SOURCE_DIR/mongo/mongod /usr/bin \
 && cp $SOURCE_DIR/mongo/mongos /usr/bin \
 && cp $SOURCE_DIR/mongo/mongobridge /usr/bin \
 && cp $SOURCE_DIR/mongo/mongoperf /usr/bin \

# Build mongodb tools
 && cd $SOURCE_DIR && git clone https://github.com/mongodb/mongo-tools \
 && cd mongo-tools && git checkout r3.3.11 && ./build.sh \
 && chmod -c 777 $SOURCE_DIR/mongo-tools/bin/* \
 && cp $SOURCE_DIR/mongo-tools/bin/* /usr/bin \
 && mkdir -p /data/db \

# Clean up of unused packages and source directory.
 && apt-get remove -y \
    zlib1g-dev \
    texinfo \
    binutils \
    binutils-dev \
    build-essential \
    bzip2 \
    flex \
    g++ \
    gcc \
    git \
    glibc-source \
    golang \
    libssl-dev \
    make \
    scons \
    subversion \
    wget \
 && rm -rf $SOURCE_DIR /opt \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* && rm -rf /var/tmp/*

VOLUME /data/db

EXPOSE 27017

CMD ["mongod"]

# End of Dockerfile