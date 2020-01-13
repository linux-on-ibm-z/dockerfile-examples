# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

	################ Dockerfile for Jenkins server version ###################
#
# This Dockerfile builds a basic installation of Jenkins server.
#
# Jenkins is an open source continuous integration tool written in Java. The project was forked from Hudson after a dispute with Oracle.
# Jenkins provides continuous integration services for software development.
# It is a server-based system running in a servlet container such as Apache Tomcat.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Jenkins server create a container from the created image and
# expose port 8080.
# docker run --name <container_name> -p <port_number>:8080 -d <image_name>
# To see the Jenkins UI, go to http://<hostname>:<port_number>/ on the web browser.
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
# Set Environment Variables
ENV JAVA_HOME=/opt/adoptjdk
ENV PATH=$JAVA_HOME/bin:$PATH
# Install dependencies
RUN apt-get update &&  apt-get install -y tar curl libfontconfig1 \
# Download AdoptJDK8
&& mkdir -p $JAVA_HOME \
&& curl -SL -o java.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u232-b09_openj9-0.17.0/OpenJDK8U-jdk_s390x_linux_openj9_8u232b09_openj9-0.17.0.tar.gz \
&& tar -C $JAVA_HOME -xzvf java.tar.gz  --strip-components=2 \
# Install Jenkins
&& wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war \
# Clean up Cache data and unused dependencies
&& rm -rf java.tar.gz   \
&& apt-get remove -y curl \
&& apt-get autoremove -y && apt-get clean \
EXPOSE 8080
CMD java -jar jenkins.war && tail -f /var/log/jenkins/jenkins.log
# End of Dockerfile
