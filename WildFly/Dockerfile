# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for WildFly (JBoss) version 17.0.0 ##########################
#
# This Dockerfile builds a basic installation of WildFly.
#
# WildFly, formerly known as JBoss AS, or simply JBoss, is an application server authored by JBoss, now developed by Red Hat.
# WildFly is written in Java, and implements the Java Platform, Enterprise Edition (Java EE) specification. 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use below command to start WildFly in standalone mode : 
#    docker run --name <container_name> -p <port_number>:8080 -p <port_number>:9990 -it <image_name> 
# Use below command to start WildFly in domain mode :
#    docker run --name <container_name> -p <port_number>:8080 -p <port_number>:9990 -it <image_name> domain.sh -b 0.0.0.0 -bmanagement 0.0.0.0
#
# To view the web console open the link  http://<wildfly-ip>:8080
#
##############################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 17.0.0.Final
ENV WILDFLY_SHA1 50bf8c48d4faf27c530af6949a225b9f1428300e
ENV JBOSS_HOME=/opt/jboss/wildfly-${WILDFLY_VER}
ENV JAVA_HOME=/opt/jdk-11.0.3+7
ENV PWD=`pwd`
ENV PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    tar \
    wget  \
 && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.3_7.tar.gz \
 && tar -xf OpenJDK11U-jdk_s390x_linux_hotspot_11.0.3_7.tar.gz -C /opt \
 && mkdir /opt/jboss && cd /opt/jboss/ \
 && wget https://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz \
 && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
 && tar -xvzf wildfly-${WILDFLY_VERSION}.tar.gz \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*\
 && rm -rf $HOME/.m2

WORKDIR $JBOSS_HOME/bin

EXPOSE 8080 9990

CMD ["standalone.sh","-b","0.0.0.0","-bmanagement","0.0.0.0"]
