# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################### Dockerfile for Apache Ignite 2.7.5 ##################################
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

ARG IGNITE_VER=2.7.5

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set Environment Variables
ENV WORKDIR /root
ENV JAVA_HOME=$WORKDIR/jdk8u192-b12_openj9-0.11.0
ENV IGNITE_HOME=$WORKDIR/apache-ignite-${IGNITE_VER}-bin
ENV PATH=$JAVA_HOME/bin:$WORKDIR/apache-ignite-${IGNITE_VER}-bin/bin:$PATH

# Install Dependencies
RUN apt-get update &&  apt-get install -y \
        wget \
        tar \
        unzip \
# Download AdoptOpenJDK 8
 && cd $WORKDIR  \
 && wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u192-b12_openj9-0.11.0/OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz \
 && tar xvf OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz \
# Install Apache Ignite
 && cd $WORKDIR  \
 && wget http://mirrors.estointernet.in/apache//ignite/${IGNITE_VER}/apache-ignite-${IGNITE_VER}-bin.zip \
 && unzip -q apache-ignite-${IGNITE_VER}-bin.zip  \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    wget \
    unzip \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  $WORKDIR/apache-ignite-${IGNITE_VER}-bin.zip $WORKDIR/OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz

# Exposing the ports.
EXPOSE 11211 47100 47500 49112

# Start the Apache Ignite server
CMD ["ignite.sh"]

# End of Dockerfile
