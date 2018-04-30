# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apache Geode version 1.4.0 #####################
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

# Build Protobuf-3.0.0
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
 && git checkout v3.0.0 \


# Add code patch

 && file1=autogen.sh \
 && sed -i '33,37d' $file1 \
 && sed -i '33i echo "Google Mock not present.  Fetching gmock-1.7.0 from the web..."' $file1 \
 && sed -i '34i curl $curlopts -L -O https://github.com/google/googlemock/archive/release-1.7.0.zip' $file1 \
 && sed -i '35i unzip -q release-1.7.0.zip' $file1 \
 && sed -i '36i rm release-1.7.0.zip' $file1 \
 && sed -i '37i mv googlemock-release-1.7.0 gmock' $file1 \
 && sed -i '38i curl $curlopts -L -O https://github.com/google/googletest/archive/release-1.7.0.zip' $file1 \
 && sed -i '39i unzip -q release-1.7.0.zip' $file1 \
 && sed -i '40i rm release-1.7.0.zip' $file1 \
 && sed -i '41i mv googletest-release-1.7.0 gmock/gtest' $file1 \


  # Generate and then run the configuration
 && ./autogen.sh \
 && ./configure \

  # Add code patch
 && file2=src/google/protobuf/stubs/atomicops_internals_generic_gcc.h \
 && sed -i '130i inline Atomic64 NoBarrier_AtomicIncrement(volatile Atomic64* ptr,' $file2 \
 && sed -i '131i                                                     Atomic64 increment) {' $file2 \
 && sed -i '132i        return __atomic_add_fetch(ptr, increment, __ATOMIC_RELAXED);' $file2 \
 && sed -i '133i }' $file2 \
 && sed -i '134i inline void NoBarrier_Store(volatile Atomic64* ptr, Atomic64 value) {' $file2 \
 && sed -i '135i        __atomic_store_n(ptr, value, __ATOMIC_RELAXED);' $file2 \
 && sed -i '136i }' $file2 \
 && sed -i '137i inline Atomic64 NoBarrier_AtomicExchange(volatile Atomic64* ptr,' $file2 \
 && sed -i '138i                                                     Atomic64 new_value) {' $file2 \
 && sed -i '139i        return __atomic_exchange_n(ptr, new_value, __ATOMIC_RELAXED);' $file2 \
 && sed -i '140i }' $file2 \
 && sed -i '141i inline Atomic64 NoBarrier_Load(volatile const Atomic64* ptr) {' $file2 \
 && sed -i '142i        return __atomic_load_n(ptr, __ATOMIC_RELAXED);' $file2 \
 && sed -i '143i }' $file2 \

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
        &&      git checkout rel/v1.4.0 \
# Build Apache Geode source
    && mkdir -p $HOME/.gradle/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.0.0 \
    && cp /usr/local/bin/protoc $HOME/.gradle/caches/modules-2/files-2.1/com.google.protobuf/protoc/3.0.0/protoc-3.0.0-linux-s390x_64.exe \
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

