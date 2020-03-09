# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for RethinkDB 2.4.0 ############################################
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
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

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

#Install Node 6.11.0
 && wget https://nodejs.org/dist/v6.11.0/node-v6.11.0-linux-s390x.tar.gz \
 && tar xvf node-v6.11.0-linux-s390x.tar.gz -C /usr \
 && export PATH=/usr/node-v6.11.0-linux-s390x/bin:$PATH  \
 && export VPYTHON_BYPASS="manually managed python not supported by chrome operations" \

#Clone and build RethinkDB
 && git clone https://github.com/rethinkdb/rethinkdb \
 && cd rethinkdb/ \
 && git checkout v2.4.0 \

#Changed for V8
 &&  cp mk/support/pkg/v8.sh mk/support/pkg/v8.sh.orig \
 && sed -i '67 i export CXXFLAGS="-fno-delete-null-pointer-checks"' mk/support/pkg/v8.sh \
 && sed -i '67 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '69d ' mk/support/pkg/v8.sh \
 && sed -i '69 i make dependencies || true'  mk/support/pkg/v8.sh \
 && sed -i '69 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '70d ' mk/support/pkg/v8.sh \
 && sed -i '70 i make s390x -j4 werror=no snapshot=off library=static'  mk/support/pkg/v8.sh \
 && sed -i '70 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '172d ' mk/support/pkg/v8.sh \
 && sed -i '172 i  for lib in libv8_{base,libbase,nosnapshot,libplatform}; do'  mk/support/pkg/v8.sh \
 && sed -i '172 s/^/        /' mk/support/pkg/v8.sh \
 

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
