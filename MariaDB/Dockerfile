# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Mariadb Server version 10.2.14 #########
#
# This Dockerfile builds a basic installation of Mariadb Server.
#
# MariaDB is a community-developed fork of the MySQL relational database management system intended to remain free under the GNU GPL. 
# Being a fork of a leading open source software system, it is notable for being led by the original developers of MySQL, who forked it due to concerns over its acquisition by Oracle. 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use the following command to start mariadb server.
# docker run --name <container name> -p <port>:3306 -d <image name>
#
# Provide custom configuration file
# docker run --name <container_name> -v <host>/my.cnf:/etc/mysql/my.cnf -d -p <port>:3306 <image_name>
#
######################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

###Install build dependencies
RUN apt-get update && apt-get install -y \
    bison \
    build-essential \ 
    cmake \
    dh-autoreconf \
    gcc \
    git \
    libboost-dev \
    libboost-program-options-dev \
    libncurses-dev \
    libpcre3-dev \
    libssl-dev \
    make \
    openssl \
    scons \
    tar \
    wget \
	hostname \

##Get MariaDB code from Git
 && cd $SOURCE_DIR && wget https://github.com/MariaDB/server/archive/mariadb-10.2.14.tar.gz \
 && tar xzf mariadb-10.2.14.tar.gz \
 && cd server-mariadb-10.2.14 \

##Get MariaDB Connector C code from git
 && cd $SOURCE_DIR && git clone git://github.com/MariaDB/mariadb-connector-c.git \
 && cd mariadb-connector-c && git checkout v3.0.2 \
 && cp -r $SOURCE_DIR/mariadb-connector-c/* $SOURCE_DIR/server-mariadb-10.2.14/libmariadb/ \

## Make changes to file to fix openssl related issue
 && cd $SOURCE_DIR/server-mariadb-10.2.14 \
 && sed -i '231d' libmariadb/include/mariadb_com.h \
 && sed -i '231 a\#define SERVER_STATUS_IN_TRANS_READONLY       8192' libmariadb/include/mariadb_com.h \
 && sed -i '231 a\#define SERVER_SESSION_STATE_CHANGED      16384' libmariadb/include/mariadb_com.h \
 && sed -i '231 a\#define SERVER_STATUS_ANSI_QUOTES        32768' libmariadb/include/mariadb_com.h \

##Build, configure, install 
 && BUILD/autorun.sh \
 && ./configure \
 && make \
 && make install \
 && groupadd -r mysql && useradd -r -g mysql mysql \
 && cd /usr/local/mysql \
 && chmod -R o+rwx . \
 && scripts/mysql_install_db \
 && sleep 20s \
 && chmod -R o+rwx . \
 && cp support-files/mysql.server /etc/init.d/mysql \

# Cleanup 
&& apt-get remove -y \
    bison \
    cmake \
    dh-autoreconf \
    git \
    make \
    pkg-config \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf $SOURCE_DIR/server-mariadb-10.2.14  $SOURCE_DIR/mariadb-10.2.14.tar.gz $SOURCE_DIR/mariadb-connector-c \ 

# Expose MariaDB default port
EXPOSE 3306

VOLUME /usr/local/mysql/data

ENV PATH=$PATH:/usr/local/mysql/bin

# Start MariaDB Server 
CMD mysqld --user=mysql

# End of Dockerfile
