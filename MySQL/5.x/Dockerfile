# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################## Dockerfile for MySQL 5.x ##################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:5.7 .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
# 
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:5.7
#       docker run --name <container_name> -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:5.7
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
FROM s390x/ubuntu:18.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG MYSQL_VERSION=5.7.31
ENV DEBIAN_FRONTEND noninteractive

# Add mysql user and group
RUN groupadd -r mysql && useradd -r -g mysql mysql

ENV TZ 'America/Toronto'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gosu \
    pwgen \
    openssl \
    perl \
    xz-utils \
    mysql-server \
    # For mysql_ssl_rsa_setup
    && gosu nobody true \
    && mkdir /docker-entrypoint-initdb.d \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld /var/lib/mysql-files && touch /mysql-init-complete \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /etc/ /var/lib/mysql-files/ /mysql-init-complete \
    && chmod 777 /var/run/mysqld \
    # comment out a few problematic configuration values
    && find /etc/mysql/ -name '*.cnf' -print0 \
	| xargs -0 grep -lZE '^(bind-address|log)' \
	| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/' \
    # don't reverse lookup hostnames, they are usually another container
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf \
    && apt autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Expose the default port
EXPOSE 3306 33060

CMD ["mysqld"]
# End of dockerfile
