# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for CouchDB version 3.5.2 ############
#
# CouchDB, is open source database software.
#
# To build CouchDB image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start CouchDB server run the below command
# docker run --name <container_name> -p <port_number>:5984 -d <image_name>
# docker run --name <container_name> -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -p <port_number>:5984 -d <image_name>
#
# To test CouchDB service, use following command:
# curl http://<host-ip>:<port_number>/
#
##################################################################################

# Base image
FROM s390x/ubuntu:22.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG ERLANG_VERSION="27.3"
ARG ELIXIR_VERSION="v1.17.3"
ARG NODE_VERSION="v18.20.8"
ARG COUCHDB_VERSION="3.5.2"

ENV SOURCE_ROOT=/tmp/source \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.utf8 \
    LC_ALL=C.utf8 \
    LD_LIBRARY_PATH=/usr/lib

WORKDIR $SOURCE_ROOT

# Install all build dependencies in one layer:
#   - CouchDB deps   (libicu-dev libmozjs-102-dev libssl-dev etc.)
#   - Erlang deps    (autoconf flex fop libncurses-dev unixodbc-dev etc.)
#   - openjdk-21-jdk (required to build Erlang)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        autoconf \
        build-essential \
        ca-certificates \
        curl \
        flex \
        fop \
        gawk \
        g++ \
        git \
        gzip \
        help2man \
        libicu-dev \
        libmozjs-102-dev \
        libncurses-dev \
        libssl-dev \
        libtool \
        libxml2-utils \
        make \
        openjdk-21-jdk \
        openssl \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        tar \
        unixodbc-dev \
        wget \
        xsltproc \
 && rm -rf /var/lib/apt/lists/*

# 1. Build and install Erlang/OTP from source
RUN cd $SOURCE_ROOT \
 && wget -q https://github.com/erlang/otp/releases/download/OTP-${ERLANG_VERSION}/otp_src_${ERLANG_VERSION}.tar.gz \
 && tar zxf otp_src_${ERLANG_VERSION}.tar.gz \
 && mv otp_src_${ERLANG_VERSION} erlang \
 && cd erlang \
 && export ERL_TOP=$(pwd) \
 && export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-s390x \
 && export PATH=$JAVA_HOME/bin:$PATH \
 && ./configure --prefix=/usr \
 && make -j$(nproc) \
 && make install \
 && cd $SOURCE_ROOT \
 && rm -rf erlang otp_src_${ERLANG_VERSION}.tar.gz \
 && erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell

# 2. Build and install Elixir
RUN cd $SOURCE_ROOT \
 && git clone https://github.com/elixir-lang/elixir.git \
 && cd elixir \
 && git checkout ${ELIXIR_VERSION} \
 && make -j$(nproc) \
 && make install \
 && elixir -v \
 && rm -rf $SOURCE_ROOT/elixir

# 3. Install Node.js (pre-built s390x binary)
RUN cd $SOURCE_ROOT \
 && mkdir -p /usr/local/lib/nodejs \
 && wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-s390x.tar.gz \
 && tar xzvf node-${NODE_VERSION}-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
 && rm node-${NODE_VERSION}-linux-s390x.tar.gz \
 && ln -s /usr/local/lib/nodejs/node-${NODE_VERSION}-linux-s390x/bin/node /usr/bin/node \
 && ln -s /usr/local/lib/nodejs/node-${NODE_VERSION}-linux-s390x/bin/npm /usr/bin/npm \
 && ln -s /usr/local/lib/nodejs/node-${NODE_VERSION}-linux-s390x/bin/npx /usr/bin/npx \
 && node -v \
 && npm -v

# 4. Build CouchDB from source
RUN cd $SOURCE_ROOT \
 && git clone https://github.com/apache/couchdb.git \
 && cd couchdb \
 && git checkout ${COUCHDB_VERSION} \
 && ./configure --spidermonkey-version 102 \
 && make release \
 && mkdir -p /opt \
 && cp -r $SOURCE_ROOT/couchdb/rel/couchdb /opt/couchdb \
 && rm -rf $SOURCE_ROOT/couchdb


# ---- Stage 2: final image ---------------------------------------------------
# Instead of apt-installing the couchdb package, we COPY the build output
# from the builder stage and install runtime libs.
FROM s390x/ubuntu:22.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Copy CouchDB release and Erlang runtime from builder
COPY --from=builder /opt/couchdb /opt/couchdb
COPY --from=builder /usr/lib/erlang /usr/lib/erlang
# /usr/bin/erl and /usr/bin/erlc are symlinks in the builder; recreate them
RUN ln -s /usr/lib/erlang/bin/erl /usr/bin/erl \
 && ln -s /usr/lib/erlang/bin/erlc /usr/bin/erlc
# Copy all four Elixir binaries (elixir, elixirc, iex, mix)
COPY --from=builder /usr/local/bin/elixir /usr/local/bin/elixir
COPY --from=builder /usr/local/bin/elixirc /usr/local/bin/elixirc
COPY --from=builder /usr/local/bin/iex /usr/local/bin/iex
COPY --from=builder /usr/local/bin/mix /usr/local/bin/mix

# Install runtime libraries required by CouchDB (SpiderMonkey, ICU)
# ca-certificates is required by couch_replicator for OS CA cert loading
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        libicu70 \
        libmozjs-102-0 \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Add CouchDB user account to make sure the IDs are assigned consistently
RUN groupadd -g 5984 -r couchdb && useradd -u 5984 -d /opt/couchdb -g couchdb couchdb

# grab tini for signal handling and zombie reaping
# see https://github.com/apache/couchdb-docker/pull/28#discussion_r141112407
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends tini; \
    rm -rf /var/lib/apt/lists/*; \
    tini --version

ENV COUCHDB_VERSION 3.5.2

# https://github.com/apache/couchdb-pkg/blob/master/debian/README.Debian
RUN set -eux; \
# Undo symlinks to /var/log and /var/lib
    mkdir -p /opt/couchdb/data /opt/couchdb/var/log; \
    chown couchdb:couchdb /opt/couchdb/data /opt/couchdb/var/log; \
    chmod 777 /opt/couchdb/data /opt/couchdb/var/log; \
# Remove file that sets logging to a file
    rm -f /opt/couchdb/etc/default.d/10-filelog.ini; \
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
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

VOLUME /opt/couchdb/data

# 5984: Main CouchDB endpoint
# 4369: Erlang portmap daemon (epmd)
# 9100: CouchDB cluster communication port
EXPOSE 5984 4369 9100
CMD ["/opt/couchdb/bin/couchdb"]
