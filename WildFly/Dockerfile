# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for WildFly (JBoss) version 16.0.0 ##########################
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
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)
ENV DEBIAN_FRONTEND noninteractive

ARG WILDFLY_VER=16.0.0.Final

ENV JAVA_HOME=/opt/jdk-11+28
ENV PWD=`pwd`
ENV SOURCE_DIR=/tmp/source
ENV JBOSS_HOME=/opt/jboss/wildfly
WORKDIR $SOURCE_DIR

ENV PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH


# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    maven \
    tar \
    wget \
 && mkdir -p /opt \
 && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11%2B28/OpenJDK11-jdk_s390x_linux_hotspot_11_28.tar.gz \
 && tar -xf OpenJDK11-jdk_s390x_linux_hotspot_11_28.tar.gz -C /opt \
 && git clone https://github.com/wildfly/wildfly.git \
 && cd wildfly && git checkout ${WILDFLY_VER}\
 && mvn install -DskipTests \
 && mkdir -p /opt/jboss/wildfly \
 && cp -a ./dist/target/wildfly-${WILDFLY_VER}/* /opt/jboss/wildfly \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    git \
    maven\
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*\
 && rm -rf $HOME/.m2

WORKDIR $JBOSS_HOME

EXPOSE 8080 9990

CMD ["standalone.sh","-b","0.0.0.0","-bmanagement","0.0.0.0"]
