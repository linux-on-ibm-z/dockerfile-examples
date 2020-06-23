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
# docker run --name <container_name> -p <port_number>:15984 -d <image_name>
#
# To test CouchDB service, use following command:
# curl http://<host-ip>:<port_number>/
#
##################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder
ARG COUCHDB_VER=3.1.0

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

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
 && cp -r $SOURCE_DIR/couchdb /usr/share/couchdb


FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV PATH=$PATH:/usr/share/couchdb/dev:/usr/bin/:/usr/local/bin/:/usr/lib/  LD_LIBRARY_PATH=/usr/lib

COPY --from=builder /usr/share/couchdb /usr/share/couchdb
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
EXPOSE 15984 25984 35984

CMD ["run"]
