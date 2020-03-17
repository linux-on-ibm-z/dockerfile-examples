# Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Linux on z Systems Dockerfile for Cassandra version 3.11.5 #########
#
# This Dockerfile builds a basic installation of Cassandra.
#
# Apache Cassandra is an open source distributed database management system designed
# to handle large amounts of data across many commodity servers, providing high
# availability with no single point of failure
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Cassandra Server create a container from the image created from Dockerfile
# docker run --name <container_name> -p <port_number>:7000 -p <port_number>:7001 -p <port_number>:7199 -p <port_number>:9042 -p <port_number>:9160 -d <image_name>
#
#################################################################################

# Base image
FROM s390x/ubuntu:18.04

ARG CASSANDRA_VERSION=3.11.5

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set environment variables
ENV SOURCE_ROOT=/root

WORKDIR $SOURCE_ROOT

RUN unset JAVA_TOOL_OPTIONS
ENV LANG="en_US.UTF-8"
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
ENV ANT_OPTS="-Xms4G -Xmx4G"
ENV JAVA_HOME=/opt/jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Installing dependencies for Cassandra
RUN apt-get update && apt-get install -y \
    automake \
    ant      \
    junit    \
    ant-optional \
    autoconf\
    git \
    g++ \
    libx11-dev \
    libxt-dev  \
    libtool \
    locales-all \
    make  \
    patch  \
    pkg-config \
    python \
    texinfo \
    tar \
    wget \
    unzip  \
# Install Adoptopenjdk8, Apache Ant and Jna
&& cd $SOURCE_ROOT \
&& mkdir -p $JAVA_HOME  \
&& wget -O jdk.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jdk_s390x_linux_hotspot_8u202b08.tar.gz \
&& tar -xf jdk.tar.gz -C $JAVA_HOME --strip-components=1    \
###
# Build JNA
&& git clone https://github.com/java-native-access/jna.git \
&& cd jna \
&& git checkout 4.2.2 \
&& ant \
##
# Build and install Apache Cassandra
&& cd $SOURCE_ROOT \
&& git clone https://github.com/apache/cassandra.git \
&& cd cassandra \
&& git checkout cassandra-${CASSANDRA_VERSION} \
&& sed -i ' s/Xss256k/Xss32m/' build.xml conf/jvm.options \
&& ant \
&& rm lib/snappy-java-1.1.1.7.jar \
&& wget -O lib/snappy-java-1.1.2.6.jar https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2.6/snappy-java-1.1.2.6.jar \
&& rm lib/jna-4.2.2.jar \
&& cp $SOURCE_ROOT/jna/build/jna.jar $SOURCE_ROOT/cassandra/lib/jna-4.2.2.jar \
&& cp -R $SOURCE_ROOT/cassandra /usr/local/ \
&& rm -rf  $SOURCE_ROOT/jna $SOURCE_ROOT/cassandra $SOURCE_ROOT/*.tar.gz  \
&& rm -rf /usr/local/cassandra/test \
# Clean up source dir and unused packages/libraries
&& apt-get remove -y \
    automake \
    autoconf\
    make  \
    patch  \
    pkg-config \
    wget \
    unzip     \
    ant    \
    junit    \
    ant-optional \
    git   \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose Ports
EXPOSE 7000 7001 7199 9042 9160

# Define mount points for conf files & data.
VOLUME ["/usr/local/cassandra/data", "/usr/local/cassandra/conf"]

# Set Path
ENV PATH $PATH:/usr/local/cassandra/bin

# Start Cassandra server
CMD ["cassandra", "-Rf"]
