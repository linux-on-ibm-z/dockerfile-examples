# © Copyright IBM Corporation 2018, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################ Dockerfile for MySQL 8.0.17 #################################################
#
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:8.0 .
#
# Start a mysql server instance examples:
# You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
# 
#       docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0
#       docker run --name some-mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:8.0
#       docker run --name some-mysql -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:8.0
# 
# For more docker configuration, please visit the official mysql dockerhub webpage:
# 
#       https://hub.docker.com/_/mysql
#
####################################################################################################################

FROM s390x/ubuntu:16.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV MYSQL_VERSION 8.0.17
ENV PATH /usr/local/mysql/bin:$PATH

RUN groupadd -r mysql && useradd -r -g mysql mysql

# Setting up timezone
ENV TZ 'America/Toronto'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Install build dependencies
RUN apt-get update && apt-get install -y \
    bison \
    cmake \
    gcc \
    g++ \
    git \
    libncurses-dev \
    libssl-dev \
    make \
    openssl \
    pkg-config

RUN apt-get update && apt-get install -y \
    # Add gosu for easy step-down from root
    gosu \
    perl \
    # For MYSQL_RANDOM_ROOT_PASSWORD
    pwgen \
    && gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

# Download mysql-server
RUN git clone -b mysql-${MYSQL_VERSION} https://github.com/mysql/mysql-server.git \
    && cd mysql-server \
    && mkdir build \
    && cd build \
    && cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=. -DWITH_SSL=system -DMYSQLX_UNIX_ADDR=/var/run/mysqld/mysqldx.sock -DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
    && make \
    && make install

RUN rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld

# Cleanup 
RUN apt-get remove -y \   
    bison\
    cmake \
    gcc \
    g++ \
    git \
    libssl-dev \
    make \
    pkg-config \
    && apt autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && rm -rf /mysql-server

VOLUME /var/lib/mysql

# Config files
COPY config/ /etc/mysql/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]