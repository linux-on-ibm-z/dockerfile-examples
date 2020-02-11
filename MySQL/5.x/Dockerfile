# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################## Dockerfile for MySQL 5.x ##################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:5.7 .
#
# Start a mysql server instance examples:
#       docker run -d -p 3306:3306 --name  <image_name>
#       docker exec -it <container_name> mysql -u root -p # default password is empty and change root password urgently
#       e.g. docker run -d -p 3306:3306 --name mysql_some_test mysql_norm:5x
#
####################################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG MYSQL_VERSION=5.7.29
ENV DEBIAN_FRONTEND noninteractive

# Add mysql user and group
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-server \
    # For mysql_ssl_rsa_setup
    openssl \
    && apt autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    # Ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld

VOLUME /var/lib/mysql

USER mysql
# Expose the default port
EXPOSE 3306 33060

CMD ["mysqld"]
