# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################# Dockerfile for R version 3.6.0 ######################
# This Dockerfile builds a basic installation of R.
#
# R is a language and environment for statistical computation and graphics.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply check the resultant image and R version, use the command:
# docker run  --name <container_name> -it <image_name> R --version
#
# To use R image from command line, use following command:
#  docker run --name <container_name> -v <R_source_file_path_in_host>:<R_source_file_path_in_container> -it <image_name> /bin/bash
#  For ex. docker run --name <container_name> -v /home/graphics:/home -it <image_name> /bin/bash
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV R_BASE_VERSION 3.6.0
ENV SOURCE_DIR=/tmp/source

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    g++ \
    gcc \
    gfortran-4.8 \
    libcurl4-openssl-dev \
    libx11-dev \
    locales \
    make \
    openjdk-8-jdk \
    r-base \
    ratfor \
    tar \
    wget \

# Download and build R
 && wget https://cran.r-project.org/src/base/R-3/R-${R_BASE_VERSION}.tar.gz \
 && tar zxvf R-${R_BASE_VERSION}.tar.gz && cd R-${R_BASE_VERSION} \
 && ./configure --with-x=no && make && make install \
 && locale-gen "en_US.UTF-8" \
 && locale-gen "en_GB.UTF-8" \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    g++ \
    gcc \
    gfortran-4.8 \
    libcurl4-openssl-dev \
    libx11-dev \
    locales \
    make \
    openjdk-8-jdk \
    ratfor \
    wget \

 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* $SOURCE_DIR/R-${R_BASE_VERSION}.tar.gz

CMD ["R"]
# End of Dockerfile
