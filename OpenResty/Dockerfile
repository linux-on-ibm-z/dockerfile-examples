# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for OpenResty version 1.17.8.2 #########
#
# This Dockerfile builds a basic installation of OpenResty.
#
# OpenResty is a full-fledged web platform that integrates the standard Nginx core, LuaJIT, 
# many carefully written Lua libraries, lots of high quality 3rd-party Nginx modules, and most of their external dependencies. 
# It is designed to help developers easily build scalable web applications, web services, and dynamic web gateways.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start OpenResty run the below command:
# docker run -d --name <container_name> -p <host_port>:80 <image>
#
# Provide custom configuration file
# docker run -d --name <container_name> -v <path_on_host>:/usr/local/openresty/nginx/conf/nginx.conf -p <host_port>:80 <image>
# Reference :
# https://openresty.org/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG RESTY_VERSION="1.17.8.2"
ARG RESTY_CONFIG_OPTIONS="\
	--without-http_redis2_module \
	--with-http_iconv_module \
	--with-http_postgres_module \
"

ENV SOURCE_ROOT=/tmp/source PATH=$PATH:/usr/local/openresty/bin

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN	DEBIAN_FRONTEND=noninteractive apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	        ca-certificates \
		dos2unix \
		gcc \
		libcurl4-openssl-dev \
		libncursesada*-dev \
		libpcre3 \
		libpcre3-dev \
		libpq-dev \
		libreadline-dev \
		libssl-dev \
		make \
		openssl \
		patch \
		perl \
		postgresql \
		tar \
		wget \
		zlib1g-dev \
	&& ln -s make /usr/bin/gmake \
# Download the source code
	&& cd $SOURCE_ROOT \
	&& wget https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz \
	&& tar -xvf openresty-${RESTY_VERSION}.tar.gz \
# Comment out the below lines in file /<source_root>/openresty-1.17.8.1/configure
	&& cd openresty-${RESTY_VERSION} \
	&& sed -i '742,785s/^/#/;717,726s/^/#/' configure \
	&& cat configure \
# Build and install OpenResty
	&& cd $SOURCE_ROOT/openresty-${RESTY_VERSION} \
	&& ./configure $RESTY_CONFIG_OPTIONS \
	&& make -j2 \
	&& make install \
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		dos2unix \
		gcc \
		make \
		openssl \
		patch \
		postgresql \
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCE_ROOT/* \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
EXPOSE 80
	
CMD ["openresty", "-g", "daemon off;"]
	
# End of Dockerfile
