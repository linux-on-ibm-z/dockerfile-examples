# © Copyright IBM Corporation 2018, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################ Dockerfile for MySQL 8.0.x #################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       DOCKER_BUILDKIT=0 docker build -t mysql:8.0.x .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
# 
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0.x
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:8.0.x
#       docker run --name <container_name> -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:8.0.x
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
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PATH /usr/local/mysql/bin:$PATH 
ENV DEBIAN_FRONTEND=noninteractive

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update && apt-get install -y --no-install-recommends gnupg && rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.16
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

ENV TZ 'America/Toronto'
RUN echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Install build dependencies
RUN apt-get update && apt-get install -y \
    bzip2 \
    openssl \
    perl \
    xz-utils \
    zstd \
    mysql-server-8.0 \
    && mkdir /docker-entrypoint-initdb.d \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld /var/lib/mysql-files/ && touch /mysql-init-complete \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /etc/ /var/lib/mysql-files/ /mysql-init-complete \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 1777 /var/run/mysqld /var/lib/mysql \
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
