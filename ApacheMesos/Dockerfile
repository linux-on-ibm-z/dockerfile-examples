########## Dockerfile for Apache Mesos version 1.2.0 #########
#
# This Dockerfile builds a basic installation of Apache Mesos.
#
# Apache Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks. 
# It can run Hadoop, Jenkins, Spark, Aurora, and other frameworks on a dynamically shared pool of nodes
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start Master of Apacahe Mesos using below command
# docker run <container_name> -it -p <container-port> -v /<host>:/<container> <image-name>  
# e.g. docker run --name mesos -it -p 5050 -v /root:/root/ mesos_img 
# 
# Official website: http://mesos.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x 
ENV MESOS_HOME=/opt/mesos
ENV PATH=$PATH:$JAVA_HOME/bin:$MESOS_HOME/bin
ENV MESOS_work_dir=/var/lib/mesos
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install  -y \
			autoconf \
			automake \
			build-essential \
			bzip2 \
			git \
			g++ \
			libapr1-dev \
			libcurl4-nss-dev \
			libsasl2-dev \
			libsasl2-modules \
			libssl-dev \
			libsvn-dev \
			libtool \
            maven \
			openjdk-8-jdk \
			python \
			python-dev \
			tar \
			wget \
			zlib1g-dev \
			
# Download and build source code of Apache Mesos
  && cd $SOURCE_DIR \
  && git clone https://github.com/apache/mesos \
  && cd $SOURCE_DIR/mesos/ \
  && git checkout 1.2.0 \
  && wget https://reviews.apache.org/r/51053/diff/raw/ -O patch \
  && git apply patch \
  && sed -i '120d' src/linux/ldcache.cpp \
  && sed -i '119 a  \  int32_t flags; \       // Flags bits determine arch and library type.' src/linux/ldcache.cpp \
  && sed -i '54d' src/slave/cmake/FindCurl.cmake \
  && sed -i '53 a   \  /usr/lib64, ' src/slave/cmake/FindCurl.cmake \
  && sed -i '54 a   \  /lib, ' src/slave/cmake/FindCurl.cmake \
  && sed -i '55 a   \  /lib64/, ' src/slave/cmake/FindCurl.cmake \
  && ./bootstrap \
  && mkdir build && cd build \
  && ../configure && make && make install \
  
#Edit the Files 
  && mkdir -p /opt/mesos/src \
  && mkdir -p /opt/mesos/src/.libs \
  
  && cp -a $SOURCE_DIR/mesos/build/bin /opt/mesos \
  && cp -a $SOURCE_DIR/mesos/build/src/master /opt/mesos/src \
  && cp $SOURCE_DIR/mesos/build/src/.libs/* /opt/mesos/src/.libs/ \
  && find $SOURCE_DIR/mesos/build/src/ -maxdepth 1 -type f -exec cp {} /opt/mesos/src \; \
  
  && sed -i "22s/.*/. \/opt\/mesos\/bin\/mesos-master-flags.sh/" /opt/mesos/bin/mesos-master.sh \
  && sed -i "24s/.*/exec \/opt\/mesos\/src\/mesos-master "${@}"/" /opt/mesos/bin/mesos-master.sh \
  && sed -i "s/\/root\/mesos\/build\/src/\/opt\/mesos\/src/g" /opt/mesos/src/mesos-master \

# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
  			autoconf \
			automake \
			build-essential \
			bzip2 \
			git \
			libtool \
            maven \
			python \
			python-dev \
			wget \
			      
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /root/.m2 $SOURCE_DIR/mesos 

VOLUME /data

# Port for Apache Mesos 
EXPOSE 5050

# Start master of Apache Mesos
CMD nohup mesos-master.sh --ip=127.0.0.1 --work_dir=/var/lib/mesos &

# End of Dockerfile
