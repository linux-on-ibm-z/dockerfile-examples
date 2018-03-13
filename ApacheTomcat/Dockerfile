############################# Dockerfile for Apache Tomcat 8.5.28 #####################################
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
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Set the Environmental Variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV CATALINA_HOME=/opt/tomcat/
ENV PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
        ant \
        gcc \
        git \
        openjdk-8-jdk \
        make \
        tar \
        wget \

# Clone and Install OpenSSL 1.1.0
 && git clone git://github.com/openssl/openssl.git && cd openssl && git checkout OpenSSL_1_1_0 \
 && ./config --prefix=/usr --openssldir=/usr/local/openssl shared \
 && make && make install \

# Clone Tomcat and build it.
 && cd /root && git clone git://github.com/apache/tomcat85.git \
 && cd tomcat85 && git checkout TOMCAT_8_5_28 \
 && cp build.properties.default build.properties \
 && ant \
 && mkdir -p $CATALINA_HOME && mv /root/tomcat85/output/build/* $CATALINA_HOME \

# Clean up source dir and unused packages/libraries
 && cd /root && ls && rm -rf  openssl tomcat-build-libs tomcat85  \
 && apt-get remove -y \
    ant \
        gcc \
        git \
        make \
        wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Port for Apache tomcat
EXPOSE 8080

# Start Apache Tomcat
CMD $CATALINA_HOME/bin/startup.sh && tail -f /opt/tomcat/logs/catalina.out

# End of Dockerfile
