############### Dockerfile for PHP MongoDBDriver 1.3.2 ####################################
# 
# To build PHP MongoDBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with PHP MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-PHP-MongoDB-Driver
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
		autoconf \
		gcc \
		make \
		openssl \
		php7.0 \
		php7.0-dev \
		php7.0-json \
		pkg-config \
		tar \
		wget \
	
# Install PHP driver for MongoDB
 && pecl install mongodb-1.3.2 \
 
# Enable PHP extension 
 && echo -e "\n; PHP driver for MongoDB\nextension=mongodb.so" | tee -a /etc/php/7.0/cli/php.ini \

 # Clean up the unwanted packages 
 && apt-get remove -y \
        autoconf \
	    gcc \
		git \
        make \
        wget \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

# End of Dockerfile
