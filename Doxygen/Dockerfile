# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Doxygen version 1.8.18 ##################
#
# This Dockerfile builds a basic installation of Doxygen
#
# Doxygen is the de facto standard tool for generating documentation from annotated C++ sources, but it also supports other popular programming languages such as C, Objective-C, C#, PHP, Java, Python, IDL.
# To build this image, from the directory containing this Dockerfile (assuming that the file is named Dockerfile):
#
# docker build -t <image_name> .
#
# To use Doxygen run below command:
# docker run --rm -i -t --name <container_name> -v <your_source_code_dir_absolute_path>:/doxygen/<your_project_name> doxygen /bin/bash
# For ex. docker run --rm -i -t --name <container_name> -v /home/myproject:/doxygen/myproject doxygen /bin/bash
#
# After the container running, go to <your_project_name> directory and generate the document for your source code by command:
# Example:
#$ cd /doxygen/myproject
#$ doxygen <configuration file>
##############################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ARG DOXYGEN_VER=Release_1_8_18

# Install dependencies
RUN apt-get update && apt-get install -y \
    bison \
    cmake \
    doxygen-gui \
    flex \
    git \
    graphviz \
    libc6 \
    libclang1-3.* \
    libgcc1 \
    libstdc++6 \
    libxml2-utils \
    python \
    qt-sdk \
 && git clone git://github.com/doxygen/doxygen.git \
 && cd doxygen && git checkout ${DOXYGEN_VER} \
  && mkdir build && cd build \
 && cmake -G "Unix Makefiles" -Dbuild_doc=NO -Dbuild_wizard=YES .. \
 && make && make install \

# Clean up of unused packages and source directory.
 && apt-get remove -y  \
    bison \
    cmake \
    flex \
    git \
    python \
    qt-sdk \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  \
 && rm -rf /usr/lib/debug/*

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
