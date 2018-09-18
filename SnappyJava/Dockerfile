# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Snappy-java version 1.1.7 #########
#
# This Dockerfile builds a basic installation of Snappy-java.
#
# snappy-java is a Java port of the snappy http://code.google.com/p/snappy/, a fast C++ compresser/decompresser developed by Google.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Result snappy java jar will be available at /artifacts location on the container
# docker run --name <container_name> -it <image> /bin/bash
#
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV SOURCE_DIR=/root
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
                autoconf \
                automake \
                git \
                libtool \
                make \
                openjdk-8-jdk \
                patch \
                pkg-config \
                tar \
                wget \
                cmake \
                curl \


# Download the Snappy-java source
&& git clone https://github.com/xerial/snappy-java.git \
&& cd snappy-java \
&& git checkout 1.1.7 \

# Checkout the source code for Snappy, build the C++ code as well as the Java classes, and use Scala SBT to package the binaries into a JAR file
&& make IBM_JDK_7=1 USE_GIT=1 GIT_SNAPPY_BRANCH=1.1.7 GIT_REPO_URL=https://github.com/google/snappy.git \

# Ensure that libsnappyjava.so is not linked against libstdc++.so and libgcc_s.so
&& ldd target/snappy-1.1.7-Linux-s390x/libsnappyjava.so \
&& cd $SOURCE_DIR \
&& mkdir artifacts \
&& cp snappy-java/target/snappy-java-1.1.7.jar artifacts/ \

# Clean up cache data and remove dependencies which are not required
&&      apt-get remove -y \
                autoconf \
                automake \
                git \
                libtool \
                make \
                openjdk-8-jdk \
                patch \
                pkg-config \
                wget \
&& apt autoremove -y && apt-get clean \
&& rm -rf snappy-java && rm -rf /tmp && rm -rf /var/lib/apt/lists/*

VOLUME /artifacts

# snappy-java provides jar library to user so no need of CMD
# End of Dockerfile
