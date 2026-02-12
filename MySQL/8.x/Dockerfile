# © Copyright IBM Corporation 2024, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################################ Dockerfile for MySQL 8.x #################################################
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       DOCKER_BUILDKIT=0 docker build -t mysql:8.x .
#
# Start a mysql server instance examples:
# You can specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD like shown below
# 
#       docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.x
#       docker run --name <container_name> -e MYSQL_RANDOM_ROOT_PASSWORD=true -d mysql:8.x
#       docker run --name <container_name> -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:8.x
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

FROM s390x/ubuntu:22.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

ENV SOURCE_ROOT=/mysql-source
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR $SOURCE_ROOT

ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/MySQL/8.4.8/patch/"

RUN apt-get update \
    && apt-get install -y libcurl4-openssl-dev patchelf curl wget tar bison cmake gcc g++ git hostname libncurses-dev libssl-dev make openssl \
    pkg-config gawk procps doxygen python-is-python3 net-tools libtirpc-dev libarchive-tools xz-utils \
    devscripts lintian debhelper po-debconf psmisc elfutils dh-apparmor \
    libldap-dev libldap2-dev libsasl2-dev libsasl2-modules-gssapi-mit libudev-dev libaio-dev zlib1g-dev \
    libnuma-dev libmecab-dev libkrb5-dev libfido2-dev \
    libprotoc-dev libprotobuf-c-dev libprotobuf-dev protobuf-c-compiler protobuf-compiler \
    && cd $SOURCE_ROOT \
    && wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.8.tar.gz \
    && tar xf mysql-8.4.8.tar.gz --strip-components=1 \
    && rm -f mysql-8.4.8.tar.gz \
    && curl -sSL ${PATCH_URL}/mt-asm.patch | git apply - \
    && curl -sSL ${PATCH_URL}/NdbHW.patch | git apply - \
    && curl -sSL ${PATCH_URL}/router-test.patch | git apply - \
    && curl -sSL ${PATCH_URL}/ut0rnd.patch | git apply - \
    && mkdir build && cd build \
    && cmake .. -DWITH_SSL=system -DWITH_PROTOBUF=system -DWITH_KERBEROS=system -DWITH_FIDO=system -DBUILD_CONFIG=mysql_release -DDEB_CODENAME=jammy -DDEB_ID=ubuntu -DDEB_RELEASE=22.04 \
    && sed -i '54i \\t\t-DWITH_AUTHENTICATION_CLIENT_PLUGINS=ON \\' debian/rules \
    && sed -i 's/make test-unit/@echo "skipping tests"/' debian/rules \
    && sed -i 's/icudt77l/icudt77b/' debian/mysql-community-server-core.install \
    && cd ../ && ln -s build/debian debian \
    && debuild -us -uc -b

# Base image
FROM s390x/ubuntu:22.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ 'America/Toronto'

COPY --from=builder /mysql-common*.deb /mysql-community-client*.deb /mysql-community-server-core*.deb /

RUN groupadd -r mysql && useradd -r -g mysql mysql \
    && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata \
    && apt-get install -y \
    bzip2 \
    openssl \
    perl \
    xz-utils \
    zstd \
    gosu \
    libsasl2-2 libaio1 libmecab2 libnuma1 \
    libprotoc-dev libprotobuf-c-dev libprotobuf-dev \
    && gosu nobody true \
    && mkdir /docker-entrypoint-initdb.d \
    # the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
    # also, we set debconf keys to make APT a little quieter
    && { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
	} | debconf-set-selections \
    && dpkg --install /mysql-common*.deb /mysql-community-client*.deb /mysql-community-server-core*.deb \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld /var/lib/mysql-files/ && touch /mysql-init-complete \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/lib/mysql-files/ /mysql-init-complete \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    && chmod 1777 /var/run/mysqld /var/lib/mysql \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && rm -f /*.deb

VOLUME /var/lib/mysql

# Copying con files
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Default port
EXPOSE 3306 33060

CMD ["mysqld"]
# End of dockerfile
