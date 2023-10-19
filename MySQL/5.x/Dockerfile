# © Copyright IBM Corporation 2017, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################## Dockerfile for MySQL 5.x ##################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# (assuming that the file is named "Dockerfile"):
#
#       docker build -t mysql:5.7.x .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
#
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7.x
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:5.7.x
#       docker run --name <container_name> -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:5.7.x
#
# To check MySQL version from within the Container run below command
#       docker exec -it <container_name> bin/mysqld --version
#
# For more docker configuration, please visit the official mysql dockerhub webpage:
#
#       https://hub.docker.com/_/mysql
#
####################################################################################################################

# Base image
FROM s390x/ubuntu:20.04 AS builder

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV DEBIAN_FRONTEND=noninteractive

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
make \
hostname \
libssl-dev pkg-config \
libncurses-dev \
libssl-dev \
tzdata \
&& git clone https://github.com/mysql/mysql-server \
&& cd mysql-server \
&& git checkout mysql-5.7.43 \
&& mkdir build \
&& cd build \
&& cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=. -DWITH_SSL=system \
&& make \
&& make install \
&& cd / \
&& rm -rf /mysql-server

# Stage 2
FROM ubuntu:20.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y \
 libncurses-dev \
 libssl-dev \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& groupadd -r mysql && useradd -r -g mysql mysql

COPY --from=builder /usr/local/mysql/bin /usr/local/mysql/bin

RUN mkdir -p /usr/local/mysql/mysql-files && chown mysql:mysql /usr/local/mysql/mysql-files && chmod 750 /usr/local/mysql/mysql-files

WORKDIR /usr/local/mysql

RUN bin/mysqld --initialize --user=mysql

VOLUME /var/lib/mysql
# Expose the default port
EXPOSE 3306 33060

CMD ["bin/mysqld_safe", "--user=mysql"]

# End of dockerfile
