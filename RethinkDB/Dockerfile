# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for RethinkDB 2.4.4 ############################################
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
ENV SOURCE_ROOT=/tmp/source
WORKDIR $SOURCE_ROOT
RUN apt-get update -y && apt-get install -y \
protobuf-compiler \
python \
libprotobuf-dev \
curl \
libcurl4-openssl-dev \
libncurses5-dev \
libjemalloc-dev \
wget \
m4 \
g++ \
git \
make \
libssl-dev \
tar \
bzip2 \
patch \
#Clone and build RethinkDB
&& cd $SOURCE_ROOT \
&& git clone https://github.com/rethinkdb/rethinkdb \
&& cd rethinkdb/ \
&& git checkout v2.4.4 \
&& ./configure --allow-fetch \ 
&& make -j4 \ 
#Install RethinkDB
&& make install \
# Clean up cache data and remove dependencies that are not required
&& apt-get remove -y \
git \
curl \
m4 \
wget \
make \
bzip2 \
g++ \
python \
protobuf-compiler \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*  $SOURCE_ROOT

VOLUME ["/data"]

WORKDIR /data

#   process cluster webui
EXPOSE 28015 29015 8080

#Start RethinkDB server
CMD rethinkdb --bind all
