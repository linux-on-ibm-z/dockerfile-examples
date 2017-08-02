#################### Dockerfile for Antlr version 4.5.1 #############################
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
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set CLASSPATH
ENV CLASSPATH /usr/share/java/antlr4-runtime-4.5.1.jar

# Install antlr4 
RUN apt-get update && apt-get install -y \
	antlr4 \
	openjdk-8-jdk \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
