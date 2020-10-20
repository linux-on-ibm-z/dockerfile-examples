# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for WildFly (JBoss) version 20.0.1 ##########################
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
FROM s390x/ubuntu:18.04

# The author
LABEL MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)


# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on
# Ubuntu so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss


# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 20.0.1.Final
ENV WILDFLY_SHA1 95366b4a0c8f2e6e74e3e4000a98371046c83eeb
ENV JBOSS_HOME=/opt/jboss/wildfly-${WILDFLY_VER}
ENV JAVA_HOME=/opt/jdk-11.0.7+10
ENV PWD=`pwd`
ENV PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    tar \
    wget  \
 && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10_openj9-0.20.0/OpenJDK11U-jdk_s390x_linux_openj9_11.0.7_10_openj9-0.20.0.tar.gz \
 && tar -xf OpenJDK11U-jdk_s390x_linux_openj9_11.0.7_10_openj9-0.20.0.tar.gz -C /opt \
 && rm -rf OpenJDK11U-jdk_s390x_linux_openj9_11.0.7_10_openj9-0.20.0.tar.gz \
 && cd /opt/jboss/ \
 && wget https://download.jboss.org/wildfly/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz \
 && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
 && tar -xvzf wildfly-${WILDFLY_VERSION}.tar.gz \
 # Move the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
 && mv wildfly-$WILDFLY_VERSION $JBOSS_HOME \
 && rm wildfly-$WILDFLY_VERSION.tar.gz \
 && chown -R jboss:0 ${JBOSS_HOME} \
 && chmod -R g+rw ${JBOSS_HOME} \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*\
 && rm -rf $HOME/.m2

# Ensure signals are forwarded to the JVM process correctly for graceful
# shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

WORKDIR $JBOSS_HOME/bin

EXPOSE 8080 9990

CMD ["standalone.sh","-b","0.0.0.0","-bmanagement","0.0.0.0"]
