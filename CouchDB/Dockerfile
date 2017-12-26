############### Dockerfile for CouchDB version 2.1.1 ############
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
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

ENV PATH=$PATH:/usr/share/couchdb/dev  LD_LIBRARY_PATH=/usr/lib

# Install following build dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    autoconf2.13 \
    automake \
    build-essential \
    erlang \
    erlang-dev \
    g++ \
    gcc \
    git \
    libicu-dev \
    libcurl4-openssl-dev \
    libncurses5-dev \
    libicu55 \
    libssl-dev \
    libmozjs185-1.0 \
    libmozjs185-dev  \
    make \
    ncurses-base \
    openssl \
    pkg-config curl  \
    python \
    rebar \
    unixodbc \
    unixodbc-dev \
    wget \
    tar \
# Download and install CouchDB
 && git clone https://github.com/apache/couchdb.git \
 && cd couchdb \
 && git checkout 2.1.1 \
 && ./configure -c --disable-docs --disable-fauxton \
 && make  \
 && cp -r $SOURCE_DIR/couchdb /usr/share/couchdb \

# Tidy and clean up
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    autoconf2.13 \
    automake \
    autoconf \
    build-essential \
    curl \
    gcc \
    git \
    g++ \
    make \
    openssl \
    pkg-config \
    unixodbc \
    unixodbc-dev \
    wget \
 && apt-get autoremove -y && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
 
# Expose ports
EXPOSE 15984 25984 35984

CMD ["run"]
