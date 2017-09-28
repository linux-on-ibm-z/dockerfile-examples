############################ Dockerfile for RethinkDB pre 2.4 ############################################
#
# This Dockerfile builds a basic installation of RethinkDB
#
# RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to 
# multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports 
# table joins, groupings, aggregations, and functions.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Rethink use:
# docker run --name <container name> -p <port1>:8080 -p <port2>:28015 -p <port3>:29015 -d <image name>
#
################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    libboost-all-dev \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    libncurses5-dev \
    libprotobuf-dev \
    libssl-dev \
    m4 \
    protobuf-compiler \
    python \
    wget \

#Clone and build RethinkDB

 && git clone https://github.com/linux-on-ibm-z/rethinkdb.git --branch next-s390x \
 && cd rethinkdb/ \
 && cp mk/support/pkg/jemalloc.sh mk/support/pkg/jemalloc.sh.orig \
 && sed -i '4d' mk/support/pkg/jemalloc.sh \
 && sed -i '4 i src_url=https://github.com/jemalloc/jemalloc/releases/download/4.1.0/jemalloc-4.1.0.tar.bz2' mk/support/pkg/jemalloc.sh \

#Changed for V8
 && cp mk/support/pkg/v8.sh mk/support/pkg/v8.sh.orig \
 && sed -i '65 i export CXXFLAGS="-fno-delete-null-pointer-checks"' mk/support/pkg/v8.sh \
 && sed -i '65 s/^/       /' mk/support/pkg/v8.sh \
 && sed -i '67d ' mk/support/pkg/v8.sh \
 && sed -i '67 i make dependencies || true'  mk/support/pkg/v8.sh \
 && sed -i '67 s/^/       /' mk/support/pkg/v8.sh \
 && sed -i '68d ' mk/support/pkg/v8.sh \
 && sed -i '68 i make s390x -j4 werror=no snapshot=off library=static'  mk/support/pkg/v8.sh \
 && sed -i '68 s/^/       /' mk/support/pkg/v8.sh \
 && sed -i '158d ' mk/support/pkg/v8.sh \
 && sed -i '158 i  for lib in libv8_{base,libbase,nosnapshot,libplatform}; do'  mk/support/pkg/v8.sh \
 && sed -i '158 s/^/    /' mk/support/pkg/v8.sh \
 && ./configure --allow-fetch \
 && make -j 4 \

#Install RethinkDB
 && make install \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    build-essential \
    git \
    make \
    m4 \
    protobuf-compiler \
    python \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  /rethinkdb

VOLUME ["/data"]

WORKDIR /data

#   process cluster webui
EXPOSE 28015 29015 8080

#Start RethinkDB server
CMD rethinkdb --bind all
