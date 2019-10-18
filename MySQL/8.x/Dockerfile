# © Copyright IBM Corporation 2018, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################ Dockerfile for MySQL 8.0.17 #################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:8.0 .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
# 
#       docker run --name <container_name> -d mysql:8.0 
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:8.0
#
# To connect MySQL Server from within the Container run below command 
#       docker exec -it <container_name> mysql -uroot -p
#
# To see randomly generated password for the root user; use below command
# 		docker logs <container_name> 2>&1 | grep GENERATED
# 
# For more docker configuration, please visit the official mysql dockerhub webpage:
# 
#       https://hub.docker.com/_/mysql
#
####################################################################################################################
# Base image
FROM s390x/ubuntu:16.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV MYSQL_VERSION 8.0.17
ENV PATH /usr/local/mysql/bin:$PATH

RUN groupadd -r mysql && useradd -r -g mysql mysql

# Install build dependencies
RUN apt-get update && apt-get install -y \
    bison \
    cmake \
    gcc \
    g++ \
    git \
    libncurses-dev \
    libssl-dev \
    libpwquality-tools \
    make \
    openssl \
    pkg-config \
# Build & Install mysql-server
    && git clone -b mysql-${MYSQL_VERSION} https://github.com/mysql/mysql-server.git \
    && cd mysql-server \
    && mkdir build \
    && cd build \
    && cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=. -DWITH_SSL=system -DMYSQLX_UNIX_ADDR=/var/run/mysqld/mysqldx.sock -DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
    && make \
    && make install && mkdir -p /docker-entrypoint-initdb.d \
    && rm -rf /var/lib/mysql  \
    && mkdir -p /var/lib/mysql /var/run/mysqld /var/lib/mysql-files/ && touch /healthcheck.cnf && touch /mysql-init-complete \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /etc/ /var/lib/mysql-files/ /healthcheck.cnf /mysql-init-complete \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld \
# Cleanup
   && apt-get remove -y \
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

# Copying con files 
COPY config/my.cnf /etc/
COPY config/conf.d/ /etc/mysql/conf.d/
COPY docker-entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /entrypoint.sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
USER mysql
HEALTHCHECK CMD /healthcheck.sh

# Default port 
EXPOSE 3306 33060

CMD ["mysqld"]
