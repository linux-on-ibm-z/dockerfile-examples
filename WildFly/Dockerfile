################# Dockerfile for WildFly (JBoss) version 10.1.0 #############
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
# To view the web console open the link  http://<wildfly-ip>:<port_number_8080>
#
##############################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)
ENV DEBIAN_FRONTEND noninteractive


ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV PATH=$PATH:$JAVA_HOME/bin
ENV PWD=`pwd`
ENV SOURCE_DIR=/tmp/source
ENV JBOSS_HOME=/opt/jboss/wildfly
WORKDIR $SOURCE_DIR

ENV PATH=$PATH:$JBOSS_HOME/bin
ENV MAVEN_OPTS="-Xmx1024m"


# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    maven \
    openjdk-8-jdk \
    tar \
    wget \
 && git clone https://github.com/wildfly/wildfly.git \
 && cd wildfly && git checkout 10.1.0.Final \
 && mvn install -DskipTests \
 && mkdir -p /opt/jboss/wildfly \
 && cp -a ./dist/target/wildfly-10.1.0.Final/* /opt/jboss/wildfly \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    git \
    maven\
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*\
 && rm -rf /tmp && rm -rf $HOME/.m2

WORKDIR $JBOSS_HOME

EXPOSE 8080 9990

CMD ["standalone.sh","-b","0.0.0.0","-bmanagement","0.0.0.0"]
