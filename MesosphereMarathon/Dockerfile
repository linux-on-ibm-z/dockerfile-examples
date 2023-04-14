# © Copyright IBM Corporation 2017, 2023
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################# Dockerfile for Marathon 1.8.222 #####################################
#
# This Dockerfile builds a basic installation of Marathon.
#
# Marathon is a production-grade container orchestration platform for Mesosphere’s Datacenter Operating System (DC/OS) and Apache Mesos.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Marathon run the below command:
# docker run --privileged --name <container_name> -p <portnumber>:8080 -d <image_name>
#
# Test in the browser by using the following url:
# http://<hostname>:<port_number>/
#
#####################################################################################################

# Base Image
FROM s390x/ubuntu:18.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG MESOS_VERSION=1.11.0
ARG REPO_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheMesos/1.11.0/patch"

# Set the Environmental Variables
ENV SOURCE_DIR='/tmp'
ENV JAVA_HOME=$SOURCE_DIR/jdk8u352-b08
ENV JAVA_TOOL_OPTIONS='-Xmx4096M'
ENV PATH=$JAVA_HOME/bin:$PATH
ENV MESOS_SYSTEMD_ENABLE_SUPPORT=false

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
        git \
        gcc \
        g++ \
        patch \
        tar \
        wget \
        build-essential \
        python-dev \
        libcurl4-nss-dev \
        libsasl2-dev \
        libsasl2-modules \
        maven \
        libapr1-dev \
        libsvn-dev \
        zlib1g-dev \
        libssl-dev \
        autoconf \
        automake \
        libtool \
        bzip2 \
        unzip \
        python-six \
        python-virtualenv \
        checkinstall

# Install IBM SEMERU JAVA 8 for Ubuntu 18.04
RUN cd $SOURCE_DIR \
    && wget https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u352-b08_openj9-0.35.0/ibm-semeru-open-jdk_s390x_linux_8u352b08_openj9-0.35.0.tar.gz \
    && tar -xzf ibm-semeru-open-jdk_s390x_linux_8u352b08_openj9-0.35.0.tar.gz \
    && java -version \
    && javac -version

# Install curl 7.64 for Ubuntu 18.04
RUN cd $SOURCE_DIR \
    && wget https://curl.haxx.se/download/curl-7.64.0.tar.gz \
    && tar -xzvf curl-7.64.0.tar.gz \
    && cd curl-7.64.0/ \
    && ./configure --disable-shared \
    && make \
    && make install \
    && ldconfig

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
# build
    && ./bootstrap \
    && mkdir build \
    && cd build \
    && ../configure \
    && make \
    && checkinstall --pkgversion=1.11.0 -y

FROM s390x/ubuntu:18.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR='/tmp'
ENV JAVA_HOME=$SOURCE_DIR/jdk8u352-b08
ENV JAVA_TOOL_OPTIONS='-Xmx2048M'
ENV PATH=$PATH:$JAVA_HOME/bin:/usr/share/zookeeper-3.4.8/bin:/usr/share/marathon/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

WORKDIR $SOURCE_DIR

COPY --from=builder /tmp/mesos/build/build_1.11.0-1_s390x.deb ./
COPY --from=builder /tmp/mesos/build/src/python/dist ./
COPY --from=builder /tmp/mesos/build/3rdparty/zookeeper-3.4.8 /usr/share/zookeeper-3.4.8/

RUN apt-get update && apt-get install -y \
    python \
    python-pip \
    libapr1 \
    libcurl3-nss \
    libsasl2-2 \
    libssl1.0.0 \
    libsvn1 \
    zlib1g \
    wget \
    tar \
# Install mesos and python packages
    && apt install ./build_1.11.0-1_s390x.deb \
    && pip install mesos.*whl \
    && ldconfig

# Install IBM SEMERU JAVA 8 for Ubuntu 18.04
RUN cd $SOURCE_DIR \
    && wget https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u352-b08_openj9-0.35.0/ibm-semeru-open-jdk_s390x_linux_8u352b08_openj9-0.35.0.tar.gz \
    && tar -xzf ibm-semeru-open-jdk_s390x_linux_8u352b08_openj9-0.35.0.tar.gz \
    && java -version \
    && javac -version

RUN cd $SOURCE_DIR \
# install Marathon
 && wget https://downloads.mesosphere.io/marathon/builds/1.8.222-86475ddac/marathon-1.8.222-86475ddac.tgz \
 && tar xzf marathon-1.8.222-86475ddac.tgz \
 && mkdir /usr/share/marathon/ \
 && cp -a $SOURCE_DIR/marathon-1.8.222-86475ddac/. /usr/share/marathon/ \
# Clean up source dir and unused packages/libraries
 && apt-get remove -y \
        patch \
        wget \
        maven \
        autoconf \
        automake \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /root/.m2 && rm -rf /tmp/source_root/m*

# Port for Marathon
EXPOSE 8080

# Create ZooKeeper config file
RUN cd /usr/share/zookeeper-3.4.8 \
&& cp conf/zoo_sample.cfg conf/zoo.cfg

RUN touch run-marathon.sh \
&& echo 'env PATH=$PATH zkServer.sh start' >> run-marathon.sh \
&& echo 'env PATH=$PATH mesos-local --ip=127.0.0.1 --quiet &' >> run-marathon.sh \
&& echo 'cd /usr/share/marathon' >> run-marathon.sh \
&& echo 'PATH=$PATH ./bin/marathon --master 127.0.0.1:5050 --zk zk://127.0.0.1:2181/marathon' >> run-marathon.sh

RUN chmod +x run-marathon.sh
# Start Marathon master
CMD ./run-marathon.sh

# End of Dockerfile

