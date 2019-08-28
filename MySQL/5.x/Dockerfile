# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################## Dockerfile for MySQL 5.x ##################################################
#
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t mysql:5.7 .
#
# Start a mysql server instance examples:
# You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
# 
#       docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7
#       docker run --name some-mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:5.7
#       docker run --name some-mysql -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:5.7
# 
# For more docker configuration, please visit the official mysql dockerhub webpage:
# 
#       https://hub.docker.com/_/mysql
#
####################################################################################################################

FROM s390x/ubuntu:16.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV DEBIAN_FRONTEND noninteractive

# Add mysql user and group
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Setting up timezone 
ENV TZ 'America/Toronto'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Add gosu for easy step-down from root
RUN set -x \
	&& apt-get update && apt-get install -y gosu \
	&& gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-server \
    # For MYSQL_RANDOM_ROOT_PASSWORD
	pwgen \
    # For mysql_ssl_rsa_setup
	openssl \
	&& rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    # Ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 777 /var/run/mysqld \
    # Remove RAND_load_file error, https://github.com/openssl/openssl/commit/1fd6afb571e85fbc37ffb522646e7ec2c6e4a11e
    && sed -i '9d;56d' /etc/ssl/openssl.cnf \
    # Disabling a few problematic configuration values
    && sed -i 's/^bind-address/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf \
    && sed -i 's/^log-error/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf \
    # Don't reverse lookup hostnames, they are usually another container
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # Backwards compatibility

ENTRYPOINT ["docker-entrypoint.sh"]

# Expose the default port
EXPOSE 3306 33060

CMD ["mysqld"]

