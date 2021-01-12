# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################## Dockerfile for Apache JMeter version 5.4 #########################################
#
# This Dockerfile builds a basic installation of Apache JMeter.
#
# The Apache JMeter application is open source software, a 100% pure JAVA application
# designed to load test functional behaviour and measure performance. It was originally
# designed for testing Web Applications but has since expanded to other test functions.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To test a JMX file use the following command:
# docker run --rm=true -v /path/to/JMX_file/filename.jmx:/filename.jmx jmeter_imagename /filename.jmx
#
#########################################################################################################

# Base image
FROM s390x/ubuntu:18.04

ARG JMETER_VER=5.4

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set Environment varibles
ENV WORKDIR=/root
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x/
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \    
    openjdk-11-jdk-headless \
    tar \    
    wget \

# Download from git and build
 && cd $WORKDIR \
 && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VER.tgz \
 && tar -xvzf apache-jmeter-$JMETER_VER.tgz \

#Remove G1GC algorithm as it is unimplemented in OpenJDK zero
 && sed -ie 185's/.*/# &/' $WORKDIR/apache-jmeter-$JMETER_VER/bin/jmeter \
 
# Clean the Cache data and remove source files and dependencies   
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Environment Variable for JMeter
ENV PATH $PATH:$WORKDIR/apache-jmeter-$JMETER_VER/bin
ENTRYPOINT ["jmeter","-n","-t"]

# End Of Dockerfile
