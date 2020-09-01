# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Htop version 2.2.0 ###############################
#
# This Dockerfile builds a basic installation of Htop.
#
# Htop is an interactive process viewer for Unix systems. It is a text-mode application (for console or X terminals) and requires ncurses.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Run htop inside a container using below command : 
# docker run --name <container_name> -it <image-name> 
# e.g. docker run --name htoptest -it htop
#
# Official website: https://hisham.hm/htop/
#
##############################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install  -y \
         gcc \
		 libcunit1-ncurses \
		 libncursesw5-dev \
		 libncursesw5 \
		 make \
		 tar \
		 wget \
		 python \
		 automake \
		 
# Download and build source code of htop
  && cd $SOURCE_DIR \
  && wget https://github.com/hishamhm/htop/archive/2.2.0.tar.gz \
  && tar xvzf 2.2.0.tar.gz \
  && cd $SOURCE_DIR/htop-2.2.0/ \
  && bash autogen.sh \
  && ./configure \
  && make \
  && make check \
  && make install \
  
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y\
         gcc \
         make \
         wget \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf  $SOURCE_DIR/htop-2.2.0.tar.gz $SOURCE_DIR/htop-2.2.0 /var/lib/apt/lists/*

# Start htop
CMD htop

# End of Dockerfile
