# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## dockerfile for Apache Kafka version 2.3.0 #########
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
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/home/
ENV JAVA_HOME=/home/jdk-11.0.4+11
ENV PATH=$PATH:$SOURCE_DIR/:$JAVA_HOME/bin
ENV VERSION=2.12-2.3.0

WORKDIR $SOURCE_DIR

# Install dependencies
RUN	apt-get update && apt-get -y install \
	git \
	unzip \
	wget \

# Download Adopt JDK
  && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.4%2B11_openj9-0.15.1/OpenJDK11U-jdk_s390x_linux_openj9_11.0.4_11_openj9-0.15.1.tar.gz \
  && tar -xvzf OpenJDK11U-jdk_s390x_linux_openj9_11.0.4_11_openj9-0.15.1.tar.gz \
  
# Download the Apache Kafka Binary
 &&	wget http://mirrors.estointernet.in/apache/kafka/2.3.0/kafka_${VERSION}.tgz \
 && tar -xvzf kafka_${VERSION}.tgz \
 && mv kafka_${VERSION} kafka

# Expose ports for Apache ZooKeeper and kafka
EXPOSE 2181 9092

WORKDIR $SOURCE_DIR/kafka/

# start zookeeper and kafka server
CMD bin/zookeeper-server-start.sh -daemon config/zookeeper.properties && sleep 20 && bin/kafka-server-start.sh config/server.properties > /dev/null

# End of Dockerfile
