# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################ Dockerfile for Scala version 2.13.3 #############################################################
# This Dockerfile builds a basic installation of Scala.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Scala container using the below command
# docker run --name <container_name> -v <source path>/file.scala:/file.scala -d <image_name> scala file.scala -o file
# Example: docker run --name scala_new -v /HelloWorld.scala:/HelloWorld.scala -d scala_img_ub scala HelloWorld.scala -o HelloWorld
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#########################################################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG SCALA_VER=2.13.3

# Install build Dependencies 
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
# Install Scala    
 && wget http://www.scala-lang.org/files/archive/scala-${SCALA_VER}.deb \
 && dpkg -i scala-${SCALA_VER}.deb \
# Clean up data and unused packages
 && rm -rf scala-${SCALA_VER}.deb \
 && apt-get remove -y wget \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 
 
 CMD ["scala","-version"]

# End of Dockerfile
