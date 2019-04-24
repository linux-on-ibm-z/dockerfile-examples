# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## dockerfile for Apache Kafka version 2.2.0 #########
#
# This Dockerfile builds a basic installation of Apache Kafka.
#
# Kafka is run as a cluster on one or more servers. The Kafka cluster stores streams of records in categories called topics.
# Each record consists of a key, a value, and a timestamp.
# In Kafka the communication between the clients and the servers is done with a simple, high-performance, language agnostic TCP protocol.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Apache Kafka run the below command:
# docker run --name <container_name>  -d <image>
#
# To check Apache kafka is running, Enter below command:
# docker exec <container_id of kafka> <any kafka related command>
# Eg. To list topic and message files:
#	 docker exec <container_id of kafka> bin/kafka-topics.sh --list --zookeeper localhost:2181
#
# Reference:
# http://kafka.apache.org/
# https://kafka.apache.org/quickstart
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$PATH:$SOURCE_DIR/gradle-5.2.1/bin:$JAVA_HOME/bin:/opt/kafka/

WORKDIR $SOURCE_DIR
# Install dependencies
RUN	apt-get update && apt-get -y install \
	git \
	openjdk-8-jdk \
	unzip \
	wget \

# Install Gradle
 &&	wget https://services.gradle.org/distributions/gradle-5.2.1-bin.zip \
 &&	unzip gradle-5.2.1-bin.zip \

# Download the source code
 &&	git clone git://github.com/apache/kafka \
 &&	cd kafka \
 &&	git checkout 2.2.0 \

# Update build parameters
 &&	sed -i '/jvmArgs/ s/Xss2m/Xss256m/' build.gradle \
 

# Setup Gradle and build the jar files
 &&	gradle \
 &&	gradle jar \

# Copy default config file
 &&	sed -i 's/-XX:+UseG1GC//' bin/kafka-run-class.sh \
 &&	cp -r $SOURCE_DIR/kafka /opt/kafka \

# Clean up cache data and remove dependencies which are not required
 &&	rm -rf $SOURCE_DIR \
 &&	apt-get -y remove \
	git \
	unzip \
	wget \
 &&	apt autoremove -y \
 &&	apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose ports for Apache ZooKeeper and kafka
EXPOSE 2181 9092

VOLUME /opt/kafka

# change work directory
WORKDIR /opt/kafka/

# start zookeeper and kafka server
CMD bin/zookeeper-server-start.sh -daemon config/zookeeper.properties && sleep 20 && bin/kafka-server-start.sh config/server.properties

# End of Dockerfile
