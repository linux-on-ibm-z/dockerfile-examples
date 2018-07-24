# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Apache ZooKeeper version 3.4.13 ######################
#
# This Dockerfile builds a basic installation of Apache ZooKeeper.
#
# ZooKeeper is a centralized service for maintaining configuration information,
# naming, providing distributed synchronization, and providing group services.
# All of these kinds of services are used in some form or another by distributed applications.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Apache ZooKeeper Server use the following command.
# docker run --name <container_name> -p <port_number>:2181 -p <port_number>:10524 -d <image_name>
#
#####################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source  PATH=$PATH:/opt/zookeeper/bin
WORKDIR $SOURCE_DIR

# Install the build dependencies
RUN apt-get update && apt-get install -y \
    ant \
    dh-autoreconf \
	git \
    libcppunit-dev \
    libcppunit-doc \
    libtool \
    make \
    openjdk-8-jdk \
	tar \
    wget \

# Download, build and install Apache ZooKeeper 
 && git clone git://github.com/apache/zookeeper \
 && cd zookeeper \
 && git checkout tags/release-3.4.13 \
 &&	ant compile \

# Build CPP unit test first
 && cd src/c \
 && ACLOCAL="aclocal -I /usr/share/aclocal" autoreconf -if \
 && ./configure \
 && make \
 && make install \
 && make distclean \
 && cd ../.. \

# Build Apache ZooKeeper source code
 && ant jar \

# Copy default config file 
 && cp conf/zoo_sample.cfg conf/zoo.cfg \
 && cp -r $SOURCE_DIR/zookeeper /opt/zookeeper \
 
# Clean up of unused packages and source directory.
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    ant \
    dh-autoreconf \
	git \
    libcppunit-dev \
    libcppunit-doc \
    libtool \
    make \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose ports for Apache ZooKeeper
EXPOSE 2181 10524

# Start Apache ZooKeeper
CMD ["zkServer.sh","start-foreground"]
