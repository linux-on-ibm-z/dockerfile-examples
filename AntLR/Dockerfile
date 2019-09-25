# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Antlr version 4.7.2 ################################
#
# This Dockerfile builds a basic installation of Antlr.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# Use below command to use Antlr:
#  docker run --rm=true --name <container_name> -v <your_grammer_code_folder_absolute_path>:<grammer_code_folder_path_in_container>  -it <image_name>  antlr4 <grammar_file_path_in_container>
#  For ex. docker run --rm=true --name <container_name> -v /home/grammer_folder:/home/myFolder  -it <image_name>  antlr4  /home/myFolder/<grammer_file_tobe_executed>
#
########################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

WORKDIR "/tmp"

# Set CLASSPATH
ENV CLASSPATH /usr/share/java/antlr4-runtime-4.7.2.jar
ENV JAVA_HOME /opt/ibm/java
ENV PATH $JAVA_HOME/bin:$PATH
ENV MAVEN_OPTS "-Xmx1G"

# Install antlr4
RUN apt-get update && apt-get install -y \
		tar \
		maven \
		wget \
		git \
		ant \
		patch \
 && ln -s `which nodejs` /usr/local/bin/node \
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.30/linux/s390x/ibm-java-s390x-sdk-8.0-5.30.bin \
 && wget https://raw.githubusercontent.com/zos-spark/scala-workbench/master/files/installer.properties.java \
 && tail -n +3 installer.properties.java | tee installer.properties \
 && chmod +x ibm-java-s390x-sdk-8.0-5.30.bin \
 && ./ibm-java-s390x-sdk-8.0-5.30.bin -r installer.properties \
 && git clone git://github.com/antlr/antlr4.git \
 && cd antlr4 && git checkout 4.7.2 \
 && sed -i 's/\[9.3.24.v20180605,)/9.4.19.v20190610/' runtime-testsuite/pom.xml \
 && mvn install -DskipTests \
 && cp tool/target/antlr4-4.7.2.jar /usr/share/java/ \
 && cp tool/target/antlr4-4.7.2-sources.jar /usr/share/java/ \
 && cp tool/target/antlr4-4.7.2-complete.jar /usr/share/java/ \
 && cp antlr4-maven-plugin/target/antlr4-maven-plugin-4.7.2.jar /usr/share/java/ \
 && cp runtime/Java/target/antlr4-runtime-4.7.2.jar /usr/share/java/ \
 && apt-get remove -y \
        git \
        wget \
        maven \
		ant \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /root/.m2 && rm -rf /tmp/installer.properties && rm -rf /tmp/ibm-java-s390x-sdk-8.0-5.30.bin  \
 && rm -rf /tmp/antlr4

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
