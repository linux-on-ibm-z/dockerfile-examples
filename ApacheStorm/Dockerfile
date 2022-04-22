# © Copyright IBM Corporation 2018, 2022.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apache Storm version 2.4.0 #########
#
# This Dockerfile builds a basic installation of Apache Storm.
#
# Apache Storm is a free and open source distributed realtime computation system. Storm is simple, can be used with any programming language.
# Storm makes it easy to reliably process unbounded streams of data, doing for realtime processing what Hadoop did for batch processing.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t storm .
#
# Setting up a minimal Storm cluster.
# Apache Zookeeper is a must for running a Storm cluster.
# Build Apache Zookeeper image using dockerfile at https://github.com/linux-on-ibm-z/dockerfile-examples/blob/master/ApacheZooKeeper/Dockerfile
# docker run -d --restart always --name some-zookeeper zookeeper
#
# The Nimbus daemon has to be connected with the Zookeeper.
# docker run -d --restart always --name some-nimbus --link some-zookeeper:zookeeper storm storm nimbus
#
# Start a single Supervisor node.
# docker run -d --restart always --name supervisor --link some-zookeeper:zookeeper --link some-nimbus:nimbus storm storm supervisor
#
# Assuming you have topology.jar, submit a topology to our cluster.
# docker run --link some-nimbus:nimbus -it --rm -v $(pwd)/topology.jar:/topology.jar storm storm jar /topology.jar org.apache.storm.starter.WordCountTopology topology
#
# Start the Storm UI.
# docker run -d -p 8080:8080 --restart always --name ui --link some-nimbus:nimbus storm storm ui
#
# Official website: http://storm.apache.org/

# Base Image
FROM s390x/ubuntu:18.04 as builder

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
    PATH=$JAVA_HOME/bin:$PATH \
    SOURCE_DIR=/tmp/source     

WORKDIR $SOURCE_DIR

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    procps \
    git \
    wget \
    ca-certificates \
    openjdk-8-jdk \
    dirmngr \
    curl; \
    rm -rf /var/lib/apt/lists/*; \
 && mkdir -p /rockdb_contents \
 && cd $SOURCE_DIR && && wget https://repo1.maven.org/maven2/org/rocksdb/rocksdbjni/6.27.3/rocksdbjni-6.27.3.jar \
 && mv $SOURCE_DIR/rocksdbjni-6.27.3.jar /rockdb_contents/rocksdbjni-6.27.3.jar \
 && apt-get remove -y \
     git \
     wget \
 && apt autoremove -y \
 && apt-get clean 



#######################################################################
FROM ubuntu:18.04
ENV STORM_CONF_DIR=/conf \
    STORM_DATA_DIR=/data \
    STORM_LOG_DIR=/logs \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
    PATH=$JAVA_HOME/bin:$PATH \
    SOURCE_DIR=/tmp/source

WORKDIR $SOURCE_DIR
COPY docker-entrypoint.sh /docker-entrypoint.sh
#
# Add a user with an explicit UID/GID and create necessary directories
RUN set -eux \
 && groupadd -r storm --gid=1000 \
 && useradd -r -g storm --uid=1000 storm \
 && mkdir -p "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR" \
 && chown -R storm:storm "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"``

# Install required packages
RUN set -eux; \
     apt-get update; \
     DEBIAN_FRONTEND=noninteractive \
     apt-get install -y --no-install-recommends \
     openjdk-8-jdk \
     bash \
     ca-certificates \
     dirmngr \
     gosu \
     python \
     procps \
     wget \
     tar; \
     rm -rf /var/lib/apt/lists/*; \
# Verify that gosu binary works
     gosu nobody true

ARG GPG_KEY=51379DA8A7AE5B02674EF15C134716AF768D9B6E
ARG DISTRO_NAME=apache-storm-2.4.0
# Download Apache Storm, verify its PGP signature, untar and clean up
RUN set -eux; \
    ddist() { \
        local f="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
            https://www-us.apache.org/dist/ \
                        https://www.apache.org/dist/ \
            https://archive.apache.org/dist/ \
        ; do \
            if wget -q -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
                success=1; \
                break; \
            fi; \
           done; \
           [ -n "$success" ]; \
    }; \
    ddist "$DISTRO_NAME.tar.gz" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz" \
 && ddist "$DISTRO_NAME.tar.gz.asc" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && for key in "$GPG_KEY" ; do \
        gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key" || \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --keyserver keyserver.pgp.com --recv-keys "$key" ;\
    done \
 && gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz" \
 && tar -xzf "$DISTRO_NAME.tar.gz" \
 && rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc" \
 && chown -R storm:storm "$DISTRO_NAME" \
 && chmod +x /docker-entrypoint.sh \
 && apt-get remove -y wget \
 && apt-get clean && apt autoremove -y

WORKDIR $SOURCE_DIR/$DISTRO_NAME
COPY --from=builder /rockdb_contents/rocksdbjni-6.27.3.jar  $SOURCE_DIR/$DISTRO_NAME/lib/rocksdbjni-6.27.3.jar
ENV PATH $PATH:$SOURCE_DIR/$DISTRO_NAME/bin

ENTRYPOINT ["/docker-entrypoint.sh"]
