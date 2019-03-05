# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Python 3.7.2 #########################################
#
# Python is an interactive high-level object-oriented language
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use Python :
# docker run --rm --name <container_name> -it <image_name> python3 <arguments>
#
# ########################### Sample python_source.py ##################################
#
# import sys
# print(sys.version)
#
# ######################################################################################
#
#####################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ARG PYTHON_VER=3.7.2

RUN apt-get update && apt-get install -y \
    g++ \
    gcc \
    libbz2-dev \ 
    libc6-dev \
    libffi-dev \
    libgdbm-dev \ 
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    make \
    tar \
    wget \
    xz-utils \ 

# Download Python from the ftp site
 && wget https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tar.xz \
 && tar -xvf Python-${PYTHON_VER}.tar.xz \

# Build Python
 && cd Python-${PYTHON_VER} \
 && ./configure --prefix=/usr/local --exec-prefix=/usr/local \
 && make \
 && make install \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    g++ \
    gcc \
    make \
    wget \
    xz-utils \ 
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/Python-${PYTHON_VER}.tar.xz /root/Python-${PYTHON_VER}

CMD python3 --version
