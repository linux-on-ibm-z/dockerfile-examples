# © Copyright IBM Corporation 2019, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Jenkins JNLP Slave version 4.7 ###################
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
FROM s390x/ubuntu:18.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG VERSION=4.7
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Set Environment Variables
ENV HOME /home/${user}
ENV JAVA_HOME=/opt/adopt/java
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update &&  apt-get install -y tar wget libfontconfig1 curl \
# Download AdoptJDK8
&& mkdir -p /opt/adopt/java && curl -SL -o adoptjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10_openj9-0.26.0/OpenJDK8U-jdk_s390x_linux_openj9_8u292b10_openj9-0.26.0.tar.gz \
&& tar -zxvf adoptjdk.tar.gz -C /opt/adopt/java --strip-components 1  \
&& rm -rf adoptjdk.tar.gz \
&& groupadd -g ${gid} ${group} \
&& useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}

LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

# Download Jenkins agent.jar
RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
# Download JNLP jenkins agent script
  && curl -o /usr/local/bin/jenkins-agent https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/4.7-1/jenkins-agent \
  && chmod 755 /usr/local/bin/jenkins-agent \
  && ln -fs /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

USER ${user}

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME ["/home/${user}/.jenkins"]
VOLUME ["${AGENT_WORKDIR}"]

WORKDIR /home/${user}

# Run JNLP jenkins agent script
ENTRYPOINT ["/usr/local/bin/jenkins-agent"]

# End of Dockerfile
