# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for SonarQube 8.4 ##############################
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

ARG SONARQUBE_VER=8.4.0.35506
ARG SONAR_SCANNER_CLI_VER=4.4.0.2170

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_ROOT=/opt
ENV SONARQUBE_HOME=/opt/sonarqube
WORKDIR $SOURCE_ROOT
ENV PATH /usr/lib/jvm/java-11-openjdk-s390x/bin:/opt/sonar-scanner-${SONAR_SCANNER_CLI_VER}-linux/bin:$PATH
ENV JAVA_VERSION="jdk-11.0.6+10" \
    JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH" \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jre_s390x_linux_hotspot_11.0.6_10.tar.gz ' \
    ESUM='bcb3f46cbad742b08c81e922e313549c029f436ac7d91ef3c9bed8e4049d67d2'


# Install dependencies
RUN apt-get update -y && apt-get -y install \
    git \
    unzip \
    wget \
    curl \
#Download AdoptJDK
 && curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL} \
 && echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c - \
 && mkdir -p /opt/java/openjdk \
 && cd /opt/java/openjdk \
 && tar -xf /tmp/openjdk.tar.gz --strip-components=1 \
 && rm -rf /var/cache/apt/* \
 && rm -rf /tmp/openjdk.tar.gz \
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
    curl \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* && rm -rf /var/tmp

USER sonarqube

# Expose port
EXPOSE 9000

# Add VOLUME
VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
ENV SONARQUBE lib/sonar-application-${SONARQUBE_VER}.jar
CMD java -jar ${SONARQUBE}
