# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for Hibernate version 5.4.18 ###########################
#
# This Dockerfile builds a basic installation of Hibernate.
#
# Hibernate ORM enables developers to more easily write applications whose data outlives the application process.
# As an Object/Relational Mapping (ORM) framework, Hibernate is concerned with data persistence
# as it applies to relational databases (via JDBC).
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start container from image
# docker run --name <container_name> -d <image>
#
# To copy Hibernate jar file :
# docker cp <container_id>:/hibernate <path_on_host>
#
# Reference:
# https://github.com/hibernate/hibernate-orm/tree/5.4.18
# http://hibernate.org/orm/releases/5.4/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG HIBERNATE_VER=5.4.18.Final

ARG ADOPTOPENJDK_URL=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.6_10.tar.gz
ARG HIBERNATE_URL=https://downloads.sourceforge.net/project/hibernate/hibernate-orm/$HIBERNATE_VER/hibernate-release-$HIBERNATE_VER.zip

ENV SOURCE_DIR=/tmp/source
ENV JAVA_HOME=/usr/share/jdk-11.0.6+10
ENV PATH=$PATH:$JAVA_HOME/bin
ENV _JAVA_OPTIONS=-Xmx10g
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV LANG=en_US.UTF-8

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y wget tar unzip \
    && wget -q -O - $ADOPTOPENJDK_URL | tar xvfz - -C /usr/share/ \
    && wget -q $HIBERNATE_URL \
    && unzip -o hibernate-release-$HIBERNATE_VER.zip \
    && mkdir -p /hibernate \
    && cp -r $SOURCE_DIR/hibernate-release-$HIBERNATE_VER/lib/required/hibernate-core-$HIBERNATE_VER.jar /hibernate \
    && apt-get autoremove -y\
    && apt autoremove -y \
    && rm -rf $SOURCE_DIR \
    && rm -rf /var/lib/apt/lists/*

VOLUME /hibernate

# Hibernate provides jar library to user so no need of CMD

# End of Dockerfile
# 
