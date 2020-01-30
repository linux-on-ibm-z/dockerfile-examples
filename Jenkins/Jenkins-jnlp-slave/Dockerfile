# © Copyright IBM Corporation 2019, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Jenkins JNLP Slave version 3.40 ###################
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

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG VERSION=3.40
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Set Environment Variables
ENV HOME /home/${user}
ENV JAVA_HOME=/usr/share/jdk8u222-b10
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update &&  apt-get install -y tar wget libfontconfig1 curl \
# Download AdoptJDK8
&& wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10_openj9-0.15.1/OpenJDK8U-jdk_s390x_linux_openj9_8u222b10_openj9-0.15.1.tar.gz \
&& tar -C /usr/share/ -xzvf OpenJDK8U-jdk_s390x_linux_openj9_8u222b10_openj9-0.15.1.tar.gz \
&& groupadd -g ${gid} ${group} \
&& useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user} 

LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

# Download Jenkins agent.jar
RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
# Download JNLP jenkins agent script
  && curl -o /usr/local/bin/jenkins-agent https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/3.40-1/jenkins-agent \
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
