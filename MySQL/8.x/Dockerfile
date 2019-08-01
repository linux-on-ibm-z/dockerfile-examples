# © Copyright IBM Corporation 2018, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for MySQL version 8.0.16 ############################################
#
# This Dockerfile builds a basic installation of MySQL.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Mysql service using this image, use following command:
# docker run --name <container name> -p <port>:3306 -d <image name>
#
##################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

###Install build dependencies
RUN apt-get update && apt-get install -y \
    bison \
    cmake \
    g++ \
	gcc \
	git \
	libncurses5-dev \
	libssl-dev \
	openssl \
	make \
	pkg-config \

##Get MySQL code
&& cd $SOURCE_DIR && git clone https://github.com/mysql/mysql-server.git \
&& cd mysql-server && git checkout tags/mysql-8.0.16 \

##Build, configure, install 
&& cmake . -DDOWNLOAD_BOOST=1 -DWITH_BOOST=. -DFORCE_INSOURCE_BUILD=1 && make && make install \

##Post installation steps
&& useradd mysql && cd /usr/local/mysql && chown -R mysql . && chgrp -R mysql . \

# Cleanup 
&& apt-get remove -y \   
    bison\
	cmake \
    git \
    make \   
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf $SOURCE_DIR/mysql-server 

# Expose the default port
EXPOSE 3306

VOLUME /usr/local/mysql/data

ENV PATH=$PATH:/usr/local/mysql/bin

# Start MySQL Server 
CMD /usr/local/mysql/bin/mysqld --initialize --user=mysql && /usr/local/mysql/bin/mysqld_safe --user=mysql

# End of Dockerfile