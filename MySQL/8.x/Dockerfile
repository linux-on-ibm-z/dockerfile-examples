# © Copyright IBM Corporation 2018, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################ Dockerfile for MySQL 8.0.20 #################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:8.0 .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
# 
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:8.0
#       docker run --name <container_name> -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:8.0
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
FROM s390x/ubuntu:20.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV MYSQL_VERSION 8.0.20-0ubuntu0.20.04.1

ENV PATH /usr/local/mysql/bin:$PATH 
ENV DEBIAN_FRONTEND=noninteractive

RUN groupadd -r mysql && useradd -r -g mysql mysql

ENV TZ 'America/Toronto'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Install build dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    pwgen \
    perl \
    xz-utils \
    gosu \
    mysql-server=$MYSQL_VERSION \   
    && gosu nobody true \
    && mkdir /docker-entrypoint-initdb.d \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld /var/lib/mysql-files/ && touch /mysql-init-complete \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /etc/ /var/lib/mysql-files/ /mysql-init-complete \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld \
# Cleanup
    && apt autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* 

VOLUME /var/lib/mysql

# Copying con files
COPY config/ /etc/mysql/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backward compatible
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Default port
EXPOSE 3306 33060

CMD ["mysqld"]
# End of dockerfile
