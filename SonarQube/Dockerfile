# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for SonarQube 7.4 #########
#
# This Dockerfile builds a basic installation of SonarQube
#
# SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use the following command to start SonarQube container.
# docker run --name <container name> -it <image name> /bin/bash
#
# To view the web console ,start container in deamon mode and open the link mentioned below
# docker run --name <container name> -p <port_number>:9000 -d <image name>
# Link : http://<sonarQube-ip>:<port_number_9000>
######################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ARG SONARQUBE_VER=7.4
ENV PATH /usr/lib/jvm/java-1.8.0-openjdk-s390x/bin:$PATH

# Install dependencies
RUN apt-get update -y && apt-get -y install \
    git \
    openjdk-8-jdk \
    perl \
    unzip \
    wget \

# Download SonarQube
 && cd $SOURCE_DIR \
 && wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VER}.zip \
 && unzip sonarqube-${SONARQUBE_VER}.zip \
 && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip \
 && unzip sonar-scanner-cli-3.2.0.1227-linux.zip \
 && rm -rf sonarqube-${SONARQUBE_VER}.zip sonar-scanner-cli-3.2.0.1227-linux.zip \
 && cp -r $SOURCE_DIR/sonarqube-${SONARQUBE_VER} $SOURCE_DIR/sonarqube \
 && cp -r $SOURCE_DIR/sonarqube /opt \

# Tidy and clean up
 &&  rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    git \
    perl \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port
EXPOSE 9000

# Add VOLUME
VOLUME  ["/opt/sonarqube/data"]

WORKDIR /opt/sonarqube/lib
CMD ["java","-jar","sonar-application-${SONARQUBE_VER}.jar"]
