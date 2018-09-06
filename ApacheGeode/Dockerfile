# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apache Geode version 1.6.0 #####################
#
# This Dockerfile builds a basic installation of Apache Geode.
#
# Apache Geode is a data management platform that provides real-time, consistent access to data-intensive
# applications throughout widely distributed cloud architectures. Geode pools memory, CPU, network resources, and
# optionally local disk across multiple processes to manage application objects and behavior. It uses dynamic replication
# and data partitioning techniques to implement high availability, improved performance, scalability, and fault tolerance.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Geode run the below command:
# docker run --name <container_name> -d <image>
#
# Reference:
# http://geode.incubator.apache.org/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x \
        PATH=$PATH:$JAVA_HOME/bin:/geode/geode-assembly/build/install/apache-geode/bin/ \
        LD_LIBRARY_PATH=/usr/local/lib \
        LANG="en_US.UTF-8" JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8" \
        _JAVA_OPTIONS=-Xmx2048m JVM_ARGS="-Xms2048m -Xmx2048m"

# Build Protobuf-3.6.1
# Installing dependencies
RUN apt-get update && apt-get install -y \
    tar \
        wget \
        autoconf \
        libtool \
        automake \
        bzip2 \
        curl \
        g++ \
        git \
        make \
        unzip \
        zlib1g-dev \


# Download and install protobuf
 && git clone https://github.com/google/protobuf.git \
 && cd protobuf \
 && git checkout v3.6.1 \
 && git config --global url."git://github.com/".insteadOf "https://github.com/"  \
 && git submodule update --init --recursive \

  # Generate and then run the configuration
 && ./autogen.sh \
 && ./configure \

# Build

 && make && make install


# Install Apache Geode dependencies
RUN     apt-get update && apt-get -y install \
        git \
        openjdk-8-jdk \

# Get the Geode source
        &&      mkdir -p $SOURCE_DIR \
        &&      cd $SOURCE_DIR \
        &&      git clone https://github.com/apache/incubator-geode.git \
        &&      cd incubator-geode/ \
        &&      git checkout rel/v1.6.0 \
# Build Apache Geode source
    && sed -i "s/3.5.1/3.6.1/g" $SOURCE_DIR/incubator-geode/gradle/dependency-versions.properties \
    && mkdir -p $HOME/.gradle/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.6.1 \
    && cp /usr/local/bin/protoc $HOME/.gradle/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.6.1/protoc-3.6.1-linux-s390x_64.exe \
    &&  sed -i '37d' ./geode-protobuf-messages/build.gradle \
        &&      sed -i "44iorg.gradle.jvmargs = -Xss1g" 'gradle.properties' \
        &&      ./gradlew build installDist -x test \
# Copy default config file
        &&      mv $SOURCE_DIR/incubator-geode /geode \
# Clean up cache data and remove dependencies which are not required
        && apt-get remove -y \
                autoconf \
                automake \
                bzip2 \
                curl \
                g++ \
                git \
                libtool \
                make \
                unzip \
                wget \
                zlib1g-dev \
        &&      apt-get autoremove -y \
        &&      apt autoremove -y \
        &&      rm -rf $HOME/.gradle \
        &&      rm -rf $SOURCE_DIR \
        &&      apt-get clean \
        &&      rm -rf /var/lib/apt/lists/*

VOLUME /geode

CMD ["gfsh"]

# End of Dockerfile

