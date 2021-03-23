# © Copyright IBM Corporation 2017, 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Mariadb Server version 10.5.9 #########
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
# docker run --name <container name> -p <port>:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d <image name>
#
# Provide custom configuration file
# docker run --name <container_name> -v <host>/my.cnf:/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=my-secret-pw -d -p <port>:3306 <image_name>
#
# For more information, see: https://hub.docker.com/_/mariadb/
######################################################################################

# Base Image
FROM s390x/ubuntu:20.04 AS builder

ARG MARIADB_VER=10.5.9

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

## Install build dependencies
# Get Galera code from Git
RUN set -ex; \
	apt-get update; \
	{ \
		echo tzdata tzdata/Areas select America; \
		echo tzdata tzdata/Zones/America select Toronto; \
	} | debconf-set-selections; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git devscripts equivs; \
	git clone https://github.com/codership/galera.git; \
	cd galera; \
	git checkout release_26.4.7; \
	git submodule init; \
	git submodule update; \
# Build Galera debian packages
	DEBIAN_FRONTEND=noninteractive mk-build-deps --install --remove --tool="apt-get -y --no-install-recommends" debian/control; \
	sed -i "9iexport CXXFLAGS=-g -O1" debian/rules; \
	dpkg-buildpackage -us -uc -b; \
# Get MariaDB code from Git
	cd $SOURCE_DIR && git clone https://github.com/MariaDB/server.git; \
	cd server; \
	git checkout mariadb-${MARIADB_VER}; \
	git submodule update --init --recursive; \
# Build MariaDB debian packages
	DEBIAN_FRONTEND=noninteractive mk-build-deps --install --remove --tool="apt-get -y --no-install-recommends" debian/control; \
	./debian/autobake-deb.sh; \
# Cleanup
 	apt-get autoremove -y; \
 	apt-get clean && rm -rf /var/lib/apt/lists/*; \
 	rm -rf $SOURCE_DIR/server SOURCE_DIR/galera

FROM s390x/ubuntu:20.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
RUN set -ex; \
	apt-get update; \
	if ! which gpg; then \
		apt-get install -y --no-install-recommends gnupg; \
	fi; \
	if ! gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# so, if we're not running gnupg 1.x, explicitly install dirmngr too
		apt-get install -y --no-install-recommends dirmngr; \
	fi; \
	rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.12
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

RUN mkdir /docker-entrypoint-initdb.d

# install "pwgen" for randomizing passwords
# install "tzdata" for /usr/share/zoneinfo/
# install "xz-utils" for .sql.xz docker-entrypoint-initdb.d files
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		pwgen \
		tzdata \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*

ENV MARIADB_MAJOR 10.5

COPY --from=builder /tmp/source/*.deb ./

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN set -ex; \
	{ \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password 'unused'; \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections; \
	apt-get update; \
	apt-get install -y \
		socat \
        libdbi-perl \
		libedit2 \
		gawk \
		iproute2 \
		lsof \
		psmisc \
		rsync \
		libaio1 \
	; \
	rm -rf /var/lib/apt/lists/*; \
# install mariadb and galera debs from builder
	DEBIAN_FRONTEND=noninteractive dpkg --install ./mariadb-common*.deb \
		./mysql-common*.deb \
		./mariadb-client*.deb \
		./libmariadb3*.deb \
		./libmysqlclient18*.deb; \
	DEBIAN_FRONTEND=noninteractive dpkg --install ./mariadb-server*.deb \
		./mariadb-backup*.deb \
		./galera-4*.deb; \
# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql; \
	mkdir -p /var/lib/mysql /var/run/mysqld; \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /var/run/mysqld; \
# comment out a few problematic configuration values
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log|user\s)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/'; \
# don't reverse lookup hostnames, they are usually another container
	echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf; \
	rm -f *.deb

VOLUME /var/lib/mysql

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
