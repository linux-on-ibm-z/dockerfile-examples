# © Copyright IBM Corporation 2017, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for WildFly (JBoss) version 28.0.0 ##########################
#
# This Dockerfile builds a basic installation of WildFly.
#
# WildFly, formerly known as JBoss AS, or simply JBoss, is an application server authored by JBoss, now developed by Red Hat.
# WildFly is written in Java, and implements the Java Platform, Enterprise Edition (Java EE) specification.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
# By default, JDK 17 will be used. For JDK 11, run below command:
# docker build -t <image_name> . --build-arg jdk=11
#
# Use below command to start WildFly in standalone mode :
#    docker run --name <container_name> -p <port_number>:8080 -p <port_number>:9990 -it <image_name>
# Use below command to start WildFly in domain mode :
#    docker run --name <container_name> -p <port_number>:8080 -p <port_number>:9990 -it <image_name> domain.sh -b 0.0.0.0 -bmanagement 0.0.0.0
#
# To view the web console open the link  http://<wildfly-ip>:8080
#
##############################################################################
ARG jdk=17

# Base Image
FROM ubuntu:20.04 AS base

FROM base AS branch-version-11
RUN apt-get update && apt-get install -y tar wget \
        && cd /opt && wget https://github.com/ibmruntimes/semeru11-binaries/releases/download/jdk-11.0.18%2B10_openj9-0.36.1/ibm-semeru-open-jdk_s390x_linux_11.0.18_10_openj9-0.36.1.tar.gz \
        && tar -xf ibm-semeru-open-jdk_s390x_linux_11.0.18_10_openj9-0.36.1.tar.gz \
        && rm ibm-semeru-open-jdk_s390x_linux_11.0.18_10_openj9-0.36.1.tar.gz
ENV JAVA_HOME=/opt/jdk-11.0.18+10

FROM base AS branch-version-17
RUN apt-get update && apt-get install -y tar wget \
        && cd /opt && wget https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.6%2B10_openj9-0.36.0/ibm-semeru-open-jdk_s390x_linux_17.0.6_10_openj9-0.36.0.tar.gz \
        && tar -xf ibm-semeru-open-jdk_s390x_linux_17.0.6_10_openj9-0.36.0.tar.gz \
        && rm ibm-semeru-open-jdk_s390x_linux_17.0.6_10_openj9-0.36.0.tar.gz
ENV JAVA_HOME=/opt/jdk-17.0.6+10

FROM branch-version-${jdk} AS final

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on
# Ubuntu so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 28.0.0.Final
ENV JBOSS_HOME=/opt/jboss/wildfly-${WILDFLY_VER}
ENV PWD=`pwd`
ENV PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH

USER root

# Install dependencies
RUN cd /opt/jboss/ \
 && wget https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz \
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
