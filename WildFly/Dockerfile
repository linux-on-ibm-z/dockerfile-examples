# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for WildFly (JBoss) version 31.0.1 ##########################
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

FROM eclipse-temurin:${jdk}

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"


WORKDIR /opt/jboss

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 31.0.1.Final
ENV WILDFLY_SHA1 f3dc65a92698173a36fa96b082eed5521f5f8494
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -L -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports in which we're interested
EXPOSE 8080 9990

# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
