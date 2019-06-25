# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for Hibernate version 5.4.3 ###########################
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
# https://github.com/hibernate/hibernate-orm/tree/5.4.3
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
ENV JAVA_HOME=/usr/share/jdk-11.0.3+7
ENV PATH=$PATH:$JAVA_HOME/bin
ENV _JAVA_OPTIONS=-Xmx10g
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV LANG=en_US.UTF-8

WORKDIR $SOURCE_DIR

# Install dependencies
RUN     apt-get update && apt-get -y install \
        git \
        libboost-locale-dev \
        libghc-old-locale-dev \
        liblocales-perl \
        locales \
        locales-all \
        wget \
# Get AdoptOpenJDK 11 with hotspot
        &&      cd $SOURCE_DIR \
        &&      wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.3_7.tar.gz \
        &&      tar -C /usr/share/ -xvzf OpenJDK11U-jdk_s390x_linux_hotspot_11.0.3_7.tar.gz \
# Build and install Hibernate
        &&      cd $SOURCE_DIR \
        &&      git clone git://github.com/hibernate/hibernate-orm.git \
        &&      cd hibernate-orm \
        &&      git checkout 5.4.3 \
# Build Hibernate
        &&      mkdir -p $HOME/.gem/jruby/1.9 \
        &&      ./gradlew build -x :documentation:renderGettingStartedGuides -x :documentation:renderIntegrationGuide -x :documentation:renderUserGuide -x test \
# copy jar files
        && mkdir -p /hibernate \
        && cp -r $SOURCE_DIR/hibernate-orm/hibernate-core/target/libs /hibernate \
# Clean up cache data and remove dependencies which are not required
        &&      apt-get -y remove \
                git \
                libboost-locale-dev \
                libghc-old-locale-dev \
                liblocales-perl \
                locales \
                locales-all \
                wget \
        &&      apt-get autoremove -y\
        &&      apt autoremove -y \
        &&      rm -rf $SOURCE_DIR \
        &&      rm -rf $HOME/.gradle/ && rm -rf $HOME/.gem/ \
        &&      apt-get clean \
        &&      rm -rf /var/lib/apt/lists/*

VOLUME /hibernate

# Hibernate provides jar library to user so no need of CMD

# End of Dockerfile
