# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Jenkins JNLP Slave ###################
#
# This Dockerfile builds an image for Jenkins slave node.
#
# This is an image for Jenkins agent (FKA "slave") using JNLP to establish connection. This agent is powered by the Jenkins Remoting library, 
# which version is being taken from the base Docker Agent image.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Jenkins slave, create a container from the created image
# 
# docker run <image-name> -url http://<jenkins-server>:port <secret> <agent name>
#
#
##################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ARG VERSION=3.28
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Set Environment Variables
ENV HOME /home/${user}
ENV JAVA_HOME=/usr/share/jdk8u192-b12_openj9-0.11.0
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update &&  apt-get install -y tar wget libfontconfig1 curl \
# Download AdoptJDK8
&& wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u192-b12_openj9-0.11.0/OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz \
&& tar -C /usr/share/ -xzvf OpenJDK8U-jdk_s390x_linux_openj9_8u192b12_openj9-0.11.0.tar.gz

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

# Download Jenkins slave.jar
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Download JNLP jenkins slave script
RUN curl -o /usr/local/bin/jenkins-slave https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/master/jenkins-slave \
    && chmod 755 /usr/local/bin/jenkins-slave

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

# Run JNLP jenkins slave script
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]

# End of Dockerfile
