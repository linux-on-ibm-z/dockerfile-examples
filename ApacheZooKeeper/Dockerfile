# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Apache ZooKeeper version 3.4.13 ######################
#
# This Dockerfile builds a basic installation of Apache ZooKeeper.
#
# ZooKeeper is a centralized service for maintaining configuration information,
# naming, providing distributed synchronization, and providing group services.
# All of these kinds of services are used in some form or another by distributed applications.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Apache ZooKeeper Server use the following command.
# docker run --name <container_name> -p <port_number>:2181 -p <port_number>:10524 -d <image_name>
#
#####################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment varibles
ENV WORKDIR /root
ENV PATH $PATH:$WORKDIR/zookeeper-3.4.13/bin

# Install the build dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
	tar \
    wget \

# Install Apache ZooKeeper
 && cd $WORKDIR \
 && wget http://www-eu.apache.org/dist/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz \
 && tar -xzvf zookeeper-3.4.13.tar.gz \

# Copy default config file 
 && cd zookeeper-3.4.13 \
 && cp conf/zoo_sample.cfg conf/zoo.cfg \
 
# Clean up of unused packages and source directory.  	    
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose ports for Apache ZooKeeper
EXPOSE 2181 10524

# Start Apache ZooKeeper
CMD ["zkServer.sh","start-foreground"]
