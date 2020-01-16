# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
# This dockerfile is no longer supported. Please find latest information from https://www.ibm.com/community/z/open-source-software/
#
############################# Dockerfile for Apache Tomcat version 9.0.27 #####################################
#
# This Dockerfile builds a basic installation of Apache Tomcat.
#
# Apache Tomcat, is an open-source web server developed by the Apache Software Foundation (ASF).
# Apache Tomcat implements several Java EE specifications including Java Servlet, JavaServer Pages (JSP), Java EL,
# and WebSocket, and provides a "pure Java" HTTP web server environment for Java code to run in.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Apache Tomcat server run the below command:
# docker run --name <container_name> -p <portnumber>:8080 -d <image_name>
#
# Test in the browser by using the following url:
# http://<hostname>:<port_number>/
#
#####################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV WORKDIR /root

# Set the Environmental Variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$PATH:$JAVA_HOME/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
        openjdk-8-jdk \
        tar \
        wget \

# download binary 
 && cd $WORKDIR && wget http://mirrors.estointernet.in/apache/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz \
 && tar -xvzf apache-tomcat-9.0.27.tar.gz \
 

# Clean up source dir and unused packages/libraries
 && cd $WORKDIR && ls && rm -rf apache-tomcat-9.0.27.tar.gz  \ 
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Port for Apache tomcat
EXPOSE 8080

# Start Apache Tomcat
CMD $WORKDIR/apache-tomcat-9.0.27/bin/startup.sh && tail -f $WORKDIR/apache-tomcat-9.0.27/logs/catalina.out

# End of Dockerfile
