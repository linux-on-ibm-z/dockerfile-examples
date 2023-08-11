# © Copyright IBM Corporation 2018, 2023.
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

FROM eclipse-temurin:11-jre

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV STORM_CONF_DIR=/conf \
    STORM_DATA_DIR=/data \
    STORM_LOG_DIR=/logs

COPY docker-entrypoint.sh /docker-entrypoint.sh

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
     bash \
     ca-certificates \
     dirmngr \
     gosu \
     gnupg \
     python2 \
     procps \
     wget \
     tar; \
     rm -rf /var/lib/apt/lists/*; \
# Verify that gosu binary works
     gosu nobody true; \
# Set default version to Python 2
    update-alternatives --install /usr/bin/python python /usr/bin/python2 0

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
    ddist "$DISTRO_NAME.tar.gz" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    ddist "$DISTRO_NAME.tar.gz.asc" "storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver hkps://keyserver.pgp.com --recv-key "$GPG_KEY" || \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$GPG_KEY" || \
    gpg --keyserver hkps://pgp.mit.edu --recv-keys "$GPG_KEY"; \
    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"; \
    chown -R storm:storm "$DISTRO_NAME" \
 && chmod +x /docker-entrypoint.sh \
 && apt-get clean && apt autoremove -y

WORKDIR $DISTRO_NAME

# This is a workaround to make storm workers run in jdk-11 and above.
# Thanks to Raul Negrean (raulnegrean) for the suggestion.
# It should be removed once the fix is included into the storm distribution.
# See more details at https://github.com/apache/storm/pull/3503 and https://github.com/31z4/storm-docker/issues/39
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        zip \
        unzip; \
    for jar in \
        lib/storm-client-2.4.0.jar \
        lib-worker/storm-client-2.4.0.jar \
    ; do \
        unzip "$jar" defaults.yaml; \
        sed -i 's/worker.childopts: "/&-XX:+IgnoreUnrecognizedVMOptions /' defaults.yaml; \
        zip -u "$jar" defaults.yaml; \
        rm defaults.yaml; \
    done; \
    apt-get purge -y --auto-remove \
        zip \
        unzip; \
    rm -rf /var/lib/apt/lists/* \
 && wget https://repo1.maven.org/maven2/org/rocksdb/rocksdbjni/6.27.3/rocksdbjni-6.27.3.jar -O /$DISTRO_NAME/lib/rocksdbjni-5.18.4.jar

ENV PATH $PATH:/$DISTRO_NAME/bin

ENTRYPOINT ["/docker-entrypoint.sh"]
