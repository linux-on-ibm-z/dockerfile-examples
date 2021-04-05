# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################### Dockerfile for UCARP 1.5.2 ##################################
#
# This Dockerfile builds a basic installation of UCARP.
#
# UCARP allows a couple of hosts to share common virtual IP addresses in order to provide automatic failover.
# It is a portable userland implementation of the secure and patent-free Common Address Redundancy Protocol (CARP, OpenBSD's alternative to
# the patents-bloated VRRP).
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start using this image, use following command:
# docker run --name <container_name> -it --cap-add=NET_ADMIN --net=host <image_name> ucarp <options>
# 
# To see the list of available options, use below command:
# docker run --name <container_name> -it --cap-add=NET_ADMIN --net=host <image_name> ucarp -h

# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
##############################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

ARG UCARP_VER=1.5.2

# The Author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment Variables
ENV WORKDIR /root

# Install Dependencies
RUN apt-get update &&  apt-get install -y \
    gcc \
        libpcap0.8-dev \
        make \
        tar \
        wget \
# Download and Install UCARP
 && cd $WORKDIR  \
 && wget https://download.pureftpd.org/pub/ucarp/ucarp-${UCARP_VER}.tar.gz \
 && tar -xvf ucarp-${UCARP_VER}.tar.gz \
 && cd ucarp-${UCARP_VER} \
 && ./configure \
 && make ARCH=s390x install-strip \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    wget \
    unzip \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* $WORKDIR/ucarp-${UCARP_VER}.tar.gz $WORKDIR/ucarp-${UCARP_VER}

# Set Entrypoint
CMD ["ucarp"]

# End of Dockerfile
