# © Copyright IBM Corporation 2018, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
########## Dockerfile for V8 JavaScript version 6.0 #########
#
# This Dockerfile builds a basic installation of V8_JavaScript.
#
# V8 is Google's open source JavaScript engine.
# V8 is written in C++ and is used in Google Chrome, the open source browser from Google.
# V8 can run standalone, or can be embedded into any C++ application.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start V8_JavaScript run the below command:
# docker run --name <container_name> -d <image>
#
# Reference:
# https://github.com/v8/v8/wiki
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH="$SOURCE_DIR/depot_tools:$PATH"
ENV VPYTHON_BYPASS="manually managed python not supported by chrome operations"

WORKDIR $SOURCE_DIR

# Install dependencies
RUN     apt-get update && apt-get -y install \
                g++ \
                gcc \
                git \
                make \
                python \
                python3 \
                subversion \
                tar \
                wget \

# Clone depot_tools from the Chromium project, as it contains a number of tools needed to build V8 6.0
        && cd $SOURCE_DIR \
        && git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git \

# Obtain the V8 source code
        && fetch v8 \
        && cd v8/ \
        && git checkout 6.0.318 \
        && gclient sync \

# Build V8 Library and V8 shared library
        && make s390x -j4 werror=no \
        && make s390x -j4 library=shared werror=no \

# V8 header files will be required to build products invoking the V8 APIs. Issue the following commands to install the header files
        && cp -vR include/* /usr/include/ \
        && chmod 644 /usr/include/libplatform/libplatform.h \
        && chmod 644 /usr/include/v8*h \

# Install the V8 libraries into /usr/local/lib/
        && cp -v out/s390x.release/lib.target/lib*.so /usr/local/lib/ \
        && chmod -f 755 /usr/local/lib/libv8.so \
        && cp -v out/s390x.release/obj.target/src/lib*.a /usr/local/lib/ \
        && cp -v out/s390x.release/obj.target/third_party/icu/lib*.a /usr/local/lib/ \
        && chmod -f 755 /usr/local/lib/libicu*.so \
        && chmod -f 644 /usr/local/lib/libv8*.a \

# Copy default config files
        && mkdir -p /v8 \
        && cp -R $SOURCE_DIR/v8/include /v8 \
        && cp -R $SOURCE_DIR/v8/out/s390x.release /v8 \

# Clean up cache data and remove dependencies which are not required
        &&      rm -rf $SOURCE_DIR \
        &&      apt-get -y remove \
                git \
                make \
                subversion \
                wget \
        &&      apt-get autoremove -y \
        &&      apt autoremove -y \
        &&      apt-get clean && rm -rf  /var/lib/apt/lists/*

VOLUME /v8

CMD /v8/s390x.release/v8_shell

# End of Dockerfile
