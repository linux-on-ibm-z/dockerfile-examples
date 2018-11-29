# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################## Dockerfile for Apache JMeter version 4.0 #########################################
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
# To create a container of Apache JMeter image run the below command:
# docker run --name <container_name> -it <image_name>
#
# To test a JMX file use the following command:
# docker run --rm=true -v /path/to/JMX_file/filename.jmx:/filename.jmx jmeter_imagename /filename.jmx
#
#########################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment varibles
ENV WORKDIR=/root
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \    
    tar \    
    wget \

# Download from git and build
 && cd $WORKDIR \
 && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-4.0.tgz \
 && tar -xvzf apache-jmeter-4.0.tgz \

#Remove G1GC algorithm as it is unimplemented in OpenJDK zero
 && sed -i '178d' $WORKDIR/apache-jmeter-4.0/bin/jmeter \
 
# Clean the Cache data and remove source files and dependencies   
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Environment Variable for JMeter
ENV PATH $PATH:$WORKDIR/apache-jmeter-4.0/bin
ENTRYPOINT ["jmeter","-n","-t"]

# End Of Dockerfile
