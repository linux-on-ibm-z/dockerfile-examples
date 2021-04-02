# © Copyright IBM Corporation 2018, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apigility version 1.5.2 ###############
#
# This Dockerfile builds a basic installation of Apigility.
#
# Apigility is an API Builder, designed to simplify creating and maintaining useful, 
# easy to consume, and well structured APIs. Regardless of your experience in API building, 
# with Apigility you can build APIs that enable mobile apps, developer communities, and any 
# other consumer controlled access to your applications. 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apigility run the below command:
# docker run --name <container_name> -p <host_port>:8080 -d <image_name>  
# 
# We can view the Apigility UI at http://<Apigility-host-ip>:<port_number>
#
# Reference:
# https://apigility.org/documentation
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04 as builder

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/tmp/source
ENV DEBIAN_FRONTEND noninteractive
# Install dependencies
RUN	apt-get update && apt-get -y install \
		apache2 \
		curl \
		gcc \
		git \
		libssl-dev \
		libxml2 \
		libxml2-dev \
		libxml-parser-perl \
		make \
		openssl \
		pkg-config \
		tar \
		wget \
		php \
		php-mbstring \
		php-xml \
# Get the source for Apigility
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/zfcampus/zf-apigility-skeleton.git \
	&&	cd zf-apigility-skeleton/ \
	&&	git checkout 1.5.2 \
# Install composer
	&&	curl -s https://getcomposer.org/installer | php -- \
	&&	./composer.phar -n update \
	&&	./composer.phar -n install \
# Copy 
	&&	mkdir -p /apigility \
	&&	cp -R $SOURCE_DIR/zf-apigility-skeleton/* /apigility 
	
FROM s390x/ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /apigility
COPY --from=builder /apigility /apigility

RUN  apt-get update && apt-get -y install \
                php \
                php-mbstring \
                php-xml \
# Put the skeleton/app in development mode
     &&  ./vendor/bin/zf-development-mode enable

VOLUME /apigility

EXPOSE 8080

CMD php -S $(hostname -i):8080 -t public -f /apigility/public/index.php

# End of Dockerfile
