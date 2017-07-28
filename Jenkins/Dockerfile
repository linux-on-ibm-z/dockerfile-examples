################ Dockerfile for Jenkins server version 2.46.3 ###################
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
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Install dependencies
RUN apt-get update && apt-get install -y \
	openjdk-8-jdk \
	wget \
 && wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add - \
 && sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
 && apt-get update && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
 && apt-get install -y jenkins \
 
# Clean up Cache data and unused dependencies
 && apt-get remove -y wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

ENTRYPOINT service jenkins restart && tail -f /var/log/jenkins/jenkins.log
# End of Dockerfile
