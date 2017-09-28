############################# Dockerfile for Marathon 1.4.5 #####################################
#
# This Dockerfile builds a basic installation of Marathon.
#
# Marathon is a production-grade container orchestration platform for Mesosphere’s Datacenter Operating System (DC/OS) and Apache Mesos.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Marathon run the below command:
# docker run --privileged --name <container_name> -p <portnumber>:8080 -d <image_name>
#
# Test in the browser by using the following url:
# http://<hostname>:<port_number>/
#
#####################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/tmp"

# Set the Environmental Variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$PATH:$JAVA_HOME/bin:/tmp/source_root/sbt/bin:/usr/share/zookeeper-3.4.8/bin:/usr/share/marathon/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
        git \
        openjdk-8-jdk \
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

# Install sbt
 && mkdir source_root && cd source_root \
 && wget https://dl.bintray.com/sbt/native-packages/sbt/0.13.11/sbt-0.13.11.tgz \
 && tar -zxf sbt-0.13.11.tgz \

# Clone and install mesos
 && git clone https://github.com/apache/mesos \
 && cd mesos && git checkout 1.2.0 \
 && wget https://reviews.apache.org/r/51053/diff/raw/ -O patch \
 && git apply patch \
 && sed -i '120d' src/linux/ldcache.cpp \
 && sed -i '119 a  \  int32_t flags; \       // Flags bits determine arch and library type.' src/linux/ldcache.cpp \
 && sed -i '54d' src/slave/cmake/FindCurl.cmake \
 && sed -i '53 a   \  /usr/lib64, ' src/slave/cmake/FindCurl.cmake \
 && sed -i '54 a   \  /lib, ' src/slave/cmake/FindCurl.cmake \
 && sed -i '55 a   \  /lib64/, ' src/slave/cmake/FindCurl.cmake \
 && ./bootstrap && mkdir build && cd build \
 && ../configure && make && make install \

# clone and install Marathon
 && cd /tmp/source_root && git clone https://github.com/mesosphere/marathon.git \
 && cd marathon && git checkout v1.4.5 \
 && sbt assembly \
 && cp -r /tmp/source_root/mesos/build/3rdparty/zookeeper-3.4.8 /usr/share/ \
 && cp -r /tmp/source_root/marathon /usr/share \

# Clean up source dir and unused packages/libraries
 && apt-get remove -y \
        git \
        patch \
        wget \
        maven \
        autoconf \
        automake \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /root/.m2 && rm -rf /tmp/source_root

# Port for Marathon
EXPOSE 8080

# start zookeeper  service
RUN cd /usr/share/zookeeper-3.4.8 \
&& cp conf/zoo_sample.cfg conf/zoo.cfg

# Start Marathon master

CMD env PATH=$PATH zkServer.sh start && env PATH=$PATH start --master local --zk zk://127.0.0.1:2181/marathon

# End of Dockerfile
