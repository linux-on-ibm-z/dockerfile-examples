# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Mariadb Server version 10.4.6 #########
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

ARG MARIADB_VER=10.4.6
ARG MARIADB_CONNECTOR_C_VER=3.1.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

###Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    make \
    wget \
    tar \
    cmake \
    libssl-dev \
    libncurses-dev \
    bison \
    scons \
    libboost-dev \
    libboost-program-options-dev \
    check \
    openssl \
    libpcre3-dev \
    libpam0g-dev \

##Get MariaDB code from Git
 && cd $SOURCE_DIR && wget https://github.com/MariaDB/server/archive/mariadb-${MARIADB_VER}.tar.gz \
 && tar xzf mariadb-${MARIADB_VER}.tar.gz \
 && cd server-mariadb-${MARIADB_VER} \

##Get MariaDB Connector C code from git
 && cd $SOURCE_DIR && git clone git://github.com/MariaDB/mariadb-connector-c.git \
 && cd mariadb-connector-c && git checkout v${MARIADB_CONNECTOR_C_VER} \
 && cp -r $SOURCE_DIR/mariadb-connector-c/* $SOURCE_DIR/server-mariadb-${MARIADB_VER}/libmariadb/ \

##Get wsrep-lib code from git
 && cd $SOURCE_DIR && git clone https://github.com/codership/wsrep-lib.git \
 && cd wsrep-lib && git checkout fd66bdef0bbcdeb3a5189c7f93319cb5f9d77ea7 \
 && git submodule update --init --recursive \
 && cp -r $SOURCE_DIR/wsrep-lib/* $SOURCE_DIR/server-mariadb-${MARIADB_VER}/wsrep-lib/ \

##Build, configure, install
 && mkdir $SOURCE_DIR/build_mariadb \
 && cd $SOURCE_DIR/build_mariadb \
 && cmake $SOURCE_DIR/server-mariadb-${MARIADB_VER} \
 && make \
 && make install \
 && groupadd -r mysql && useradd -r -g mysql mysql \
 && cd /usr/local/mysql \
 && chown -R mysql . \
 && chmod -R o+rwx . \
 && scripts/mysql_install_db \
 && sleep 20s \
 && chmod -R o+rwx . \
 && cp support-files/mysql.server /etc/init.d/mysql \

# Cleanup
&& apt-get remove -y \
    bison \
    cmake \
    git \
    make \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf $SOURCE_DIR/server-mariadb-${MARIADB_VER}  $SOURCE_DIR/mariadb-${MARIADB_VER}.tar.gz $SOURCE_DIR/mariadb-connector-c $SOURCE_DIR/wsrep-lib $SOURCE_DIR/build_mariadb \

# Expose MariaDB default port
EXPOSE 3306

VOLUME /usr/local/mysql/data

ENV PATH=$PATH:/usr/local/mysql/bin

# Start MariaDB Server
CMD mysqld --user=mysql

# End of Dockerfile
