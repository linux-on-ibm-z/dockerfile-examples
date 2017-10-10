########## Dockerfile for Sysdig version 0.17.0 #########
#
# This Dockerfile builds a basic installation of Sysdig.
#
# Sysdig is open source, system-level exploration: capture system state and activity from a running Linux instance, then save, filter and analyze.
# Sysdig is scriptable in Lua and includes a command line interface and a powerful interactive UI, csysdig, that runs in your terminal. 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start container from image & start an application in production mode
# docker run --name <container_name> -d <image>  
# 
# The official website
# https://www.sysdig.org/
#################################################################################
#			-: Some instructions to be followed :-
#
#	1. copy /sysdig-0.17.0 from container to host:
#		docker cp <container_id>:/sysdig-0.17.0 <path_on_host>
#
#	2. Insert sysdig driver module, perform below steps:
#		cd <path_on_host>/sysdig-0.17.0 
#		/sbin/insmod sysdig-probe.ko
#
#	3. Install lua5.1 and lua5.1-dev on host
#
#	4. Set PATH variable
#		export PATH=$PATH:<path_on_host>/sysdig-0.17.0/sysdig
#
#	5. Run any sysdig command
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCEDIR=/tmp/source

WORKDIR $SOURCEDIR

# Install dependencies
RUN apt-get update \
	&& apt-get install -y \
		cmake \
		gcc \
		g++ \
		linux-headers-$(uname -r) \
		lua5.1 \
		lua5.1-dev \
		patch \
		tar \
		wget \	
	
# Download source code
	&& cd $SOURCEDIR \
	&& wget https://github.com/draios/sysdig/archive/0.17.0.tar.gz \
	&& tar -xvzf 0.17.0.tar.gz \
	&& VALUE=$(uname -r) \
	&& cd sysdig-0.17.0 \
	&& mkdir build \

# Configure Sysdig
	&& cd build \
	&& cmake -DUSE_BUNDLED_LUAJIT=OFF .. \
	&& sed -i "s@\$(shell uname -r)@$VALUE@" driver/Makefile.dkms \
	&& ln -s /usr/src/*$VALUE /lib/modules/$VALUE/build \

# Build and Install Sysdig
	&& make \
	&& make install \
	
# Copy important content from build
	&& mkdir -p /sysdig-0.17.0 \
	&& cp $SOURCEDIR/sysdig-0.17.0/build/driver/sysdig-probe.ko /sysdig-0.17.0 \
	&& cp -r $SOURCEDIR/sysdig-0.17.0/build/userspace/sysdig /sysdig-0.17.0 \
	
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		cmake \
		gcc \
		g++ \
		linux-headers-$(uname -r) \
		lua5.1 \
		lua5.1-dev \
		patch \
		wget \
	&&	apt-get autoremove -y\
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCEDIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
VOLUME /sysdig-0.17.0

# End of Dockerfile
