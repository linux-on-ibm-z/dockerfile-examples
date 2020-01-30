# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 8.1 ##############################
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
FROM s390x/ubuntu:18.04

ARG SONARQUBE_VER=8.1.0.31237
ARG SONAR_SCANNER_CLI_VER=4.2.0.1873

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_ROOT=/opt
ENV SONARQUBE_HOME=/opt/sonarqube
WORKDIR $SOURCE_ROOT
ENV PATH /usr/lib/jvm/java-11-openjdk-s390x/bin:/opt/sonar-scanner-${SONAR_SCANNER_CLI_VER}-linux/bin:$PATH

# Install dependencies
RUN apt-get update -y && apt-get -y install \
    git \
    openjdk-11-jdk \
    unzip \
    wget \
# Download SonarQube
 && cd $SOURCE_ROOT \
 && wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VER}.zip \
 && unzip sonarqube-${SONARQUBE_VER}.zip \
 && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_CLI_VER}-linux.zip \
 && unzip sonar-scanner-cli-${SONAR_SCANNER_CLI_VER}-linux.zip \
 && rm -rf sonarqube-${SONARQUBE_VER}.zip sonar-scanner-cli-${SONAR_SCANNER_CLI_VER}-linux.zip \
 && mv sonarqube-${SONARQUBE_VER} sonarqube \
# Create sonarqube user
 && groupadd -r sonarqube \
 && useradd -r -g sonarqube sonarqube \
 && usermod -aG sudo sonarqube \
 && chown sonarqube:sonarqube -R $SONARQUBE_HOME \
# Tidy and clean up
 && apt-get remove -y \
    git \
    perl \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

USER sonarqube

# Expose port
EXPOSE 9000

# Add VOLUME
VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
ENV SONARQUBE lib/sonar-application-${SONARQUBE_VER}.jar
CMD java -jar ${SONARQUBE}
