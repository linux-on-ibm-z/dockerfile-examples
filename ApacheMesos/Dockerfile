# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########################################## Dockerfile for Apache Mesos 1.9.0 ###################################################
#
# This Dockerfile builds and install Apache Mesos 1.9.0 from source using Ubuntu 16:04 on s390x.
#
# Apache Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks.
# It can run Hadoop, Jenkins, Spark, Aurora, and other frameworks on a dynamically shared pool of nodes.
#
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mesos:1.9.0 .
#
# To simply run the docker image and provide a bash shell:
#
#       docker run --name some-mesos -it mesos:1.9.0 /bin/bash
#
# Simple example of running Mesos on your local machine:
# Starting Mesos master:
#
#       docker run --name mesos-master -p 5050:5050 -ti mesos:1.9.0 mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos --no-hostname_lookup
#
# Starting Mesos agent:
#
#       docker run --name mesos-agent -ti mesos:1.9.0 mesos-agent --master=<mesos_master-ip>:5050 --work_dir=/var/lib/mesos --launcher=posix
#
# Official website: http://mesos.apache.org/
#
#########################################################################################################################

FROM s390x/ubuntu:16.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG MESOS_VERSION=1.9.0
ARG REPO_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheMesos/1.9.0/patch"

ENV SOURCE_DIR='/tmp'
ENV JAVA_HOME=/opt/java-1.8.0-ibm
ENV JVM_DIR=$JAVA_HOME/jre/lib/s390x/default
ENV JAVA_TEST_LDFLAGS="-L$JVM_DIR -R$JVM_DIR -Wl,-ljvm -ldl"
ENV JAVA_JVM_LIBRARY=$JAVA_HOME/jre/lib/s390x/default/libjvm.so
ENV PATH=$JAVA_HOME/bin:$PATH
ENV MESOS_SYSTEMD_ENABLE_SUPPORT=false

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    bzip2 \
    curl \
    gcc \
    g++ \
    git \
    libapr1-dev \
    libcurl4-nss-dev \
    libsasl2-dev \
    libssl-dev \
    libsvn-dev \
    libtool \
    make \
    maven \
    patch \
    python-dev \
    python-six \
    tar \
    wget \
    zlib1g-dev

# Download and install IBM JDK 8
RUN cd $SOURCE_DIR \
    && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.41/linux/s390x/ibm-java-s390x-sdk-8.0-5.41.bin \
    && echo -en 'INSTALLER_UI=silent\nUSER_INSTALL_DIR=/opt/java-1.8.0-ibm\nLICENSE_ACCEPTED=TRUE' > installer.properties \
    && bash ibm-java-s390x-sdk-8.0-5.41.bin -i silent -f installer.properties

# Download and build source code of Apache Mesos
RUN cd $SOURCE_DIR \
    && git clone -b$MESOS_VERSION https://github.com/apache/mesos \
    && cd mesos \

# Bundling gRPC-1.11.0
    && cd 3rdparty \
    && git clone -b v1.11.0 https://github.com/grpc/grpc.git grpc-1.11.0 \
    && cd grpc-1.11.0/ \
    && git submodule update --init third_party/cares \
    && cd .. \
    && tar zcf grpc-1.11.0.tar.gz --exclude .git grpc-1.11.0 \
    && rm -rf grpc-1.11.0 \

# Add patch to update gRPC version
    && sed -i -e 's/1.10.0/1.11.0/g' versions.am \
    && sed -i -e 's/1.10.0/1.11.0/g' ../src/python/native_common/ext_modules.py.in \

# Add patch for protobuf
    && cd $SOURCE_DIR/mesos \
    && curl -o "protobuf-3.5.0.patch" $REPO_URL/protobuf-3.5.0.patch \
    && cat protobuf-3.5.0.patch >> 3rdparty/protobuf-3.5.0.patch \
    && rm protobuf-3.5.0.patch \

    && ./bootstrap \
    && mkdir build \
    && cd build \
    && ../configure \
    && make \
    && make install

# Clean up the unwanted packages and clear the source directory
RUN apt-get remove -y \
    autoconf \
    build-essential \
    bzip2 \
    git \
    libtool \
    maven \
    python \
    python-dev \
    python-six \
    wget \
    && apt-get autoremove -y \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Port for Apache Mesos
EXPOSE 5050

# End of Dockerfile
