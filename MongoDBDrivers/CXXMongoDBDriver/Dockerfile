############### Dockerfile for CXX MongoBDriver 3.1.3 ####################################
#
# 
# To build CXX MongoBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with CXX MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-CXX-MongoDB-Driver
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"
ENV PATH=/usr/local:$PATH

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
    curl \
    dh-autoreconf \
    git \
    libboost-dev \
    libclang1-3.6 \
    libpkgconfig-perl \
    libtool \
    openssl \
    pkg-config \
    tar \
    wget \
# Install cmake 3.7.1 
 && wget https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz  \
 && tar xzf cmake-3.7.1.tar.gz && cd cmake-3.7.1 \
 && ./bootstrap --prefix=/usr \
 && make && make install -e LD_LIBRARY_PATH=/opt/gcc4.8/lib64/ \
 && cmake --version \
# Install libmongoc driver
 && cd ../  && rm -rf mongo-c-driver \
 && git clone https://github.com/mongodb/mongo-c-driver.git \
 && cd mongo-c-driver \
 && git checkout r1.5 \
 && ./autogen.sh \
 && ./configure \
 && make clean && make && make install \
# Install mongo-cxx-driver
 && cd ../ && rm -rf r3.1.3.tar.gz \
 && curl -OL https://github.com/mongodb/mongo-cxx-driver/archive/r3.1.3.tar.gz \
 && tar -xzf r3.1.3.tar.gz \
 && cd mongo-cxx-driver-r3.1.3/build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
# Only for MNMLSTC polyfill
 && make EP_mnmlstc_core \
# Once MNMLSTC is installed, or if you are using a different polyfill, build and install the driver:
 && make && make install \
#clean up
 && apt-get remove -y \
	curl \
    git \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

ENV LD_LIBRARY_PATH=/usr/local/lib/
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
	
