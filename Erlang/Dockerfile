# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Erlang version 21.0 ####################
#
# This Dockerfile builds a basic installation of Erlang.
#
#
# Erlang is a programming language used to build massively scalable soft real-time systems with requirements on high availability. Some of its uses are in telecoms, banking, e-commerce, computer telephony and instant messaging.
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a container with Erlang image.
# docker run --name <container_name> -it <image_name> /bin/bash
#
# Use below command to use help option for Erlang
# docker run --rm=true --name <container_name> -it <image_name> erl <argument>
# For ex. docker run --rm=true --name <container_name> -it <image_name> erl --help
#
###########################################################################

# Base image
FROM s390x/ubuntu:16.04

# Maintainer
MAINTAINER LoZ Open Source Ecosystem

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
	fop \
    g++ \
    gcc \
    libncurses-dev \
    libncurses5-dev \
    libssl-dev \
    libwxgtk3.0-dev \
    libxml2-utils \
    make \
    openjdk-8-jdk \
    openssl \
    perl \
    tar \
    unixodbc \
    unixodbc-dev \
    wget \
    xsltproc \    

# Download and build the erlang
 && wget http://www.erlang.org/download/otp_src_21.0.tar.gz \
 && tar zxf otp_src_21.0.tar.gz && cd otp_src_21.0 \
 && export ERL_TOP=$(pwd) && ./configure --prefix=/usr \
 && make && make install \

 # Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    g++ \
    gcc \
    libncurses-dev \
    libncurses5-dev \
    libssl-dev \
    make \
    openjdk-8-jdk \
    openssl \
    perl \
    unixodbc \
    unixodbc-dev \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


CMD ["erl"]

# End of Dockerfile
