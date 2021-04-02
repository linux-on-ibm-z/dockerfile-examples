############### Dockerfile for Java MongoDBDriver 3.6.1 ####################################
# 
# To build Java MongoBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with Java MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-java-MongoDB-Driver
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#############################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$JAVA_HOME/bin:$PATH:/usr/local

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
      git \
	  openjdk-8-jdk \
	
# Download and configure the java Driver 
 && git clone https://github.com/mongodb/mongo-java-driver.git  \
 && cd mongo-java-driver \
 && git checkout r3.6.1 \
 && ./gradlew assemble \
 
#clean up the unwanted packages 
 && apt-get remove -y \
	    git \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

# End of Dockerfile
