############# Dockerfile for Apache Maven version 3.5.0 #######################################################################################
#
# This Dockerfile builds a basic installation of Maven.
#
# Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can managea project's build, reporting and documentation from a central piece of information.
#
# To build this image, from the directory containing this Dockerfile.
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a container of Maven image, use following command:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# To use Maven image from command line, use following command:
# docker run --rm=true --name <container_name> -v <path_to_project_on_host>:<path_on_container> <image_name> <maven_command>
# For ex. docker run --rm --name <container_name> -v /prj/HelloWorld:/tmp/source maven_img mvn install
#
##############################################################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# Maintainer
MAINTAINER LoZ Open Source Ecosystem

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV M3_HOME=$SOURCE_DIR/maven
ENV PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    tar \
    wget \
    maven \
    openjdk-8-jdk \
# Download and build maven code
 && wget http://apache.cs.utah.edu/maven/maven-3/3.5.0/source/apache-maven-3.5.0-src.tar.gz \
 && tar -zxvf apache-maven-3.5.0-src.tar.gz \
 && cd apache-maven-3.5.0 \
 && mvn -DdistributionTargetDir="$M3_HOME" clean install \
 &&  apt-get remove -y maven \
 && cp -r $M3_HOME/ /usr/share/ \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \

# Clean up and Tidy 
 && apt-get remove -y \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /root/.m2 $SOURCE_DIR

# Set Entrypoint
CMD ["mvn","-v"]