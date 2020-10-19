# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for CouchDB version 3.1.0 ############
#
# CouchDB, is open source database software.
#
# To build CouchDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start CouchDB server run the below command
# docker run --name <container_name> -p <port_number>:5984 -d <image_name>
#
# To test CouchDB service, use following command:
# curl http://<host-ip>:<port_number>/
#
##################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder
ARG COUCHDB_VER=3.1.0

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

ENV PATH=$PATH:/usr/share/couchdb/dev  LD_LIBRARY_PATH=/usr/lib
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/CouchDB/${COUCHDB_VER}/patch"
# Install following build dependencies
RUN apt-get update \
 && apt-get install -y build-essential pkg-config ncurses-base g++-5 gcc-5 python python3 python3-pip python3-venv curl git patch wget tar make zip autoconf2.13 automake libicu-dev libcurl4-openssl-dev libncurses5-dev locales libncurses-dev libssl-dev unixodbc-dev libwxgtk3.0-dev openjdk-8-jdk xsltproc fop libxml2-utils\
 && rm -rf /usr/bin/gcc /usr/bin/g++ /usr/bin/cc \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc \
 && ln -s /usr/bin/g++-5 /usr/bin/g++ \
 && ln -s /usr/bin/gcc /usr/bin/cc \
# Download and Install Erlang
 && cd $SOURCE_DIR \
 && wget http://www.erlang.org/download/otp_src_22.2.tar.gz \
 && tar zxf otp_src_22.2.tar.gz && rm otp_src_22.2.tar.gz \
 && cd otp_src_22.2 \
 && export ERL_TOP=$SOURCE_DIR/otp_src_22.2 \
 && ./configure --prefix=/usr \
 && make \
 && make install \
# Download and Install Elixir
 && git clone https://github.com/elixir-lang/elixir.git \
 && cd elixir \
 && git checkout v1.10.2 \
 && export LANG=en_US.UTF-8 \
 && locale-gen en_US.UTF-8 \
 && make \
 && make install \
# Download and Install Spider Monkey
 && cd $SOURCE_DIR \
 && wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz \
 && tar zxf js185-1.0.0.tar.gz  \
 && cd js-1.8.5 \
 && cd $SOURCE_DIR \
 && curl -o jsval.h.diff $PATCH_URL/jsval.h.diff \
 && patch "$SOURCE_DIR/js-1.8.5/js/src/jsval.h" jsval.h.diff \
 && curl -o jsvalue.h.diff $PATCH_URL/jsvalue.h.diff \
 && patch "$SOURCE_DIR/js-1.8.5/js/src/jsvalue.h" jsvalue.h.diff \
 && curl -o Makefile.in.diff $PATCH_URL/Makefile.in.diff \
 && patch "$SOURCE_DIR/js-1.8.5/js/src/Makefile.in" Makefile.in.diff \
 && cd "$SOURCE_DIR/js-1.8.5/js/src"    \
 && autoconf2.13 \
 && mkdir $SOURCE_DIR/js-1.8.5/js/src/build_OPT.OBJ \
 && cd $SOURCE_DIR/js-1.8.5/js/src/build_OPT.OBJ \
 && ../configure --prefix=/usr \
 && make \
 && make install \
# Download and install CouchDB
 && cd $SOURCE_DIR \
 && git clone https://github.com/apache/couchdb.git \
 && cd couchdb \
 && git checkout ${COUCHDB_VER} \
 && ./configure --dev \
 && make  \
 && make release \
 && cp -r $SOURCE_DIR/couchdb/rel/couchdb /usr/share/couchdb


FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV PATH=$PATH:/usr/share/couchdb/dev:/usr/bin/:/usr/local/bin/:/usr/lib/  LD_LIBRARY_PATH=/usr/lib

COPY --from=builder /usr/share/couchdb /opt/couchdb
COPY --from=builder /usr/lib/erlang /usr/lib/erlang
COPY --from=builder /usr/bin/erlc /usr/bin/erlc
COPY --from=builder /usr/bin/erl /usr/bin/erl
COPY --from=builder /usr/local/bin/elixir /usr/local/bin/elixir
COPY --from=builder /usr/lib/libmozjs185* /usr/lib/
RUN apt-get update && apt-get install -y \
        python3 python3-pip python3-venv \
&& apt-get autoremove -y && apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*
# Expose ports
# Add CouchDB user account to make sure the IDs are assigned consistently
RUN groupadd -g 5984 -r couchdb && useradd -u 5984 -d /opt/couchdb -g couchdb couchdb

# be sure GPG and apt-transport-https are available and functional
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg \
     ; \
    rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root and tini for signal handling and zombie reaping
# see https://github.com/apache/couchdb-docker/pull/28#discussion_r141112407
ENV GOSU_VERSION 1.11
ENV TINI_VERSION 0.18.0
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends wget; \
    rm -rf /var/lib/apt/lists/*; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    \
# install gosu
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf; \
    for server in $(shuf -e pgpkeys.mit.edu \
        ha.pool.sks-keyservers.net \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu) ; do \
    gpg --batch --keyserver $server --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
    done; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu; \
    gosu nobody true; \
    \
# install tini
    wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$dpkgArch"; \
    wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$dpkgArch.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf; \
    for server in $(shuf -e pgpkeys.mit.edu \
        ha.pool.sks-keyservers.net \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu) ; do \
    gpg --batch --keyserver $server --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && break || : ; \
    done; \
    gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini; \
    rm -rf "$GNUPGHOME" /usr/local/bin/tini.asc; \
    chmod +x /usr/local/bin/tini; \
    apt-get purge -y --auto-remove wget; \
    tini --version

# http://docs.couchdb.org/en/latest/install/unix.html#installing-the-apache-couchdb-packages
ENV GPG_COUCH_KEY \
# gpg: key D401AB61: public key "Bintray (by JFrog) <bintray@bintray.com> imported
    8756C4F765C9AC3CB6B85D62379CE192D401AB61
RUN set -xe; \
    export GNUPGHOME="$(mktemp -d)"; \
    echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf; \
    for server in $(shuf -e pgpkeys.mit.edu \
        ha.pool.sks-keyservers.net \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu) ; do \
        gpg --batch --keyserver $server --recv-keys $GPG_COUCH_KEY && break || : ; \
    done; \
    gpg --batch --export $GPG_COUCH_KEY > /etc/apt/trusted.gpg.d/couchdb.gpg; \
    command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "$GNUPGHOME"; \
    apt-key list

ENV COUCHDB_VERSION 3.1.0

# https://github.com/apache/couchdb-pkg/blob/master/debian/README.Debian
RUN set -xe; \
    apt-get update; \
    \
# Undo symlinks to /var/log and /var/lib
    mkdir -p /opt/couchdb/data /opt/couchdb/var/log; \
    chown couchdb:couchdb /opt/couchdb/data /opt/couchdb/var/log; \
    chmod 777 /opt/couchdb/data /opt/couchdb/var/log; \
# Remove file that sets logging to a file
# Check we own everything in /opt/couchdb. Matches the command in dockerfile_entrypoint.sh
    find /opt/couchdb \! \( -user couchdb -group couchdb \) -exec chown -f couchdb:couchdb '{}' +; \
# Setup directories and permissions for config. Technically these could be 555 and 444 respectively
# but we keep them as 755 and 644 for consistency with CouchDB defaults and the dockerfile_entrypoint.sh.
    find /opt/couchdb/etc -type d ! -perm 0755 -exec chmod -f 0755 '{}' +; \
    find /opt/couchdb/etc -type f ! -perm 0644 -exec chmod -f 0644 '{}' +; \
# only local.d needs to be writable for the docker_entrypoint.sh
    chmod -f 0777 /opt/couchdb/etc/local.d; \
# apt clean-up
    rm -rf /var/lib/apt/lists/*;

# Add configuration
COPY --chown=couchdb:couchdb 10-docker-default.ini /opt/couchdb/etc/default.d/
COPY --chown=couchdb:couchdb vm.args /opt/couchdb/etc/

COPY docker-entrypoint.sh /usr/local/bin
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
RUN chmod +x /docker-entrypoint.sh  
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

VOLUME /opt/couchdb/data

# 5984: Main CouchDB endpoint
# 4369: Erlang portmap daemon (epmd)
# 9100: CouchDB cluster communication port
EXPOSE 5984 4369 9100
CMD ["/opt/couchdb/bin/couchdb"]
