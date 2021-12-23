# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for OpenResty version 1.19.9.1 #########
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
FROM ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG RESTY_VERSION="1.19.9.1"

ARG RESTY_CONFIG_OPTIONS="\
	--with-pcre-jit \
	--with-ipv6 \
	--without-http_redis2_module \
	--with-http_iconv_module \
	--with-http_postgres_module"

ENV SOURCE_ROOT=/tmp/source PATH=/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin:$PATH

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN	DEBIAN_FRONTEND=noninteractive apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		tar \
		wget \
		make \
		gcc \
		build-essential \
		dos2unix \
		patch \
		libpcre3-dev \
		libpq-dev \
		openssl \
		libssl-dev \
		perl \
		zlib1g-dev \
	&& ln -s make /usr/bin/gmake \
# Download the source code
	&& cd $SOURCE_ROOT \
	&& wget https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz \
	&& tar -xvf openresty-${RESTY_VERSION}.tar.gz \
# Replace source luajit2 with latest luajit2
	&& rm -rf $SOURCE_ROOT/openresty-${RESTY_VERSION}/bundle/LuaJIT-2.1-20210510  \
        && mkdir $SOURCE_ROOT/openresty-${RESTY_VERSION}/bundle/LuaJIT-2.1-20210510 \
        && wget https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20211210.tar.gz \
        && tar -xvzf v2.1-20211210.tar.gz \
        && mv luajit2-2.1-20211210/* openresty-${RESTY_VERSION}/bundle/LuaJIT-2.1-20210510 \ 
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
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCE_ROOT/* \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["openresty", "-g", "daemon off;"]
# End of Dockerfile
