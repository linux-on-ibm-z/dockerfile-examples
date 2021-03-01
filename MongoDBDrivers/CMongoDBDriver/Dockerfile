############### Dockerfile for C MongoDBDriver 1.9.3 ####################################
# 
# To build C MongoBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with C MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-C-MongoDB-Driver
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV PATH=/usr/local:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
      autoconf \
      automake \
      gcc \
      libtool \
      make \
      pkg-config \
	  tar \
      wget \
	
# Download and configure the C Driver 
 && wget -O mongo-c-driver-1.9.3.tar.gz  https://github.com/mongodb/mongo-c-driver/releases/download/1.9.3/mongo-c-driver-1.9.3.tar.gz  \
 && tar -xzf mongo-c-driver-1.9.3.tar.gz \
 && cd mongo-c-driver-1.9.3 \
 && ./configure \
 && make && make install \

#clean up the unwanted packages 
 && apt-get remove -y \
       wget \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /root/mongo-c-driver-1.9.3.tar.gz /var/lib/apt/lists/* 

# End of Dockerfile
