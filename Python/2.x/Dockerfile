# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Python-2.7.15 #########################################
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
# docker run --rm --name <container_name> -it <image_name> python <arguments>
#
# Below is an example to display Python version:
# docker run --rm --name <container_name> -v /home/python_source.py:/home/python_source.py -it <image_name> python /home/python_source.py
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

RUN apt-get update && apt-get install -y \
    bzip2 \
    curl \
    g++ \
    gcc \
    libbz2-dev \ 
    libc6-dev \
    libgdbm-dev \ 
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    make \
    patch \
    tar \
    wget \
    xz-utils \ 
	zlib1g-dev \
	libdb1-compat \
	libdb-dev \
	tk8.5-dev \
	gdb \

# Download Python from the ftp site
 && wget https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tar.xz \
 && tar -xvf Python-2.7.15.tar.xz \
 
# Build Python
 && ./configure --prefix=/usr/local --exec-prefix=/usr/local \
 && make \
 && make install \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    bzip2 \
    curl \
    g++ \
    gcc \
    make \
    patch \
    wget \
    xz-utils \ 
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/Python-2.7.15.tar.xz /root/Python-2.7.15

CMD python --version
