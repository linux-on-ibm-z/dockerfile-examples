# © Copyright IBM Corporation 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################### Dockerfile for Apache Ignite 2.7.0 ##################################
#
# This Dockerfile builds a basic installation of Apache Ignite.
#
# Apache Ignite™ is memory-centric distributed database, caching, and processing platform for
# transactional, analytical, and streaming workloads delivering in-memory speeds at petabyte scale
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Apache Ignite server using this image, use following command:
# docker run --name <container_name> -d <image_name>
#
##############################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

# The Author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment Variables
ENV SOURCE_DIR=/root
WORKDIR $SOURCE_DIR
ENV JAVA_HOME=$SOURCE_DIR/jdk8u192-b12_openj9-0.11.0
ENV PATH=$JAVA_HOME/bin:$PATH
ARG IGNITE_VER=2.7.0

# Install Dependencies
RUN apt-get update &&  apt-get install -y \
    maven \
        wget \
        git \
        tar \
        zip \
        unzip \
# Download AdoptOpenJDK 8
 && cd $SOURCE_DIR \
 && wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u192-b12_openj9-0.11.0/OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz \
 && tar xvf OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz \
# Download the source code of Apache Ignite
 && cd $SOURCE_DIR \
 && wget http://mirrors.estointernet.in/apache//ignite/${IGNITE_VER}/apache-ignite-${IGNITE_VER}-src.zip \
 && unzip -q apache-ignite-${IGNITE_VER}-src.zip  \
# Install the jars
 && cd /tmp \
 && wget http://clojars.org/repo/ring-cors/ring-cors/0.1.5/ring-cors-0.1.5.jar \
 && cd $SOURCE_DIR/apache-ignite-${IGNITE_VER}-src  \
 && mvn install:install-file -Dfile=/tmp/ring-cors-0.1.5.jar -DgroupId=ring-cors -DartifactId=ring-cors -Dversion=0.1.5 -Dpackaging=jar \
 && cd /tmp \
 && wget http://central.maven.org/maven2/net/minidev/json-smart/2.3/json-smart-2.3.jar \
 && cd $SOURCE_DIR/apache-ignite-${IGNITE_VER}-src  \
 && mvn install:install-file -Dfile=/tmp/json-smart-2.3.jar -DgroupId=net.minidev -DartifactId=json-smart -Dversion=2.3-SNAPSHOT -Dpackaging=jar  \
# Build Apache Ignite
 && mvn clean package -DskipTests  \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    wget \
    git \
    zip \
    unzip \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  $SOURCE_DIR/apache-ignite-${IGNITE_VER}-src.zip

# Exposing the ports.
EXPOSE 11211 47100 47500 49112

# Start the Apache Ignite server
WORKDIR $SOURCE_DIR/apache-ignite-${IGNITE_VER}-src
CMD ["bin/ignite.sh"]

# End of Dockerfile
