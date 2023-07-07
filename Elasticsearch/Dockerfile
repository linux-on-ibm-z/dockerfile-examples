# © Copyright IBM Corporation 2017, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)


##################################### Dockerfile for Elasticsearch version 8.8.1 ########################################
#
# This Dockerfile builds a basic installation of Elasticsearch.
#
# Elasticsearch is a search server based on Lucene. It provides a distributed, multitenant-capable
# full-text search engine with an HTTP web interface and schema-free JSON documents.
#
# The vm_max_map_count kernel setting needs to be set to at least 262144 for production use using the below command.(See "https://github.com/docker-library/elasticsearch/issues/111")
# sysctl -w vm.max_map_count=262144
#
# For more information, see https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Elasticsearch container using the below command
# docker run --name <container_name> -p <port>:9200 -p <port>:9300 -e "discovery.type=single-node" -d <image_name>
#
# Start Elastic search with configuration file
# For ex. docker run --name <container_name> -v <path_on_host>/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -p <port>:9200 -p <port>:9300 -e "discovery.type=single-node" -d <image_name>
#
##############################################################################################################
################################################################################
# Build stage 0 `builder`:
# Extract Elasticsearch artifact
################################################################################

FROM s390x/ubuntu:20.04 AS builder

ARG ELASTICSEARCH_VER=8.8.1

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LANG="en_US.UTF-8"
ENV SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/opt/temurin/java
ENV JAVA17_HOME=/opt/temurin/java
ENV PATH=$JAVA_HOME/bin:$PATH
ENV GRADLE_USER_HOME="/tmp/.gradle"
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Elasticsearch/${ELASTICSEARCH_VER}/patch/elasticsearch.patch"
ENV TEMURIN_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_s390x_linux_hotspot_17.0.7_7.tar.gz"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gzip \
    tar \
    wget \
    locales \
    make \
    gcc \
    g++

# `tini` is a tiny but valid init for containers. This is used to cleanly
# control how ES and any child processes are shut down.
#
# The tini GitHub page gives instructions for verifying the binary using
# gpg, but the keyservers are slow to return the key and this can fail the
# build. Instead, we check the binary against the published checksum.
RUN set -eux ; \
    tini_bin="" ; \
    case "$(arch)" in \
        aarch64) tini_bin='tini-arm64' ;; \
        x86_64)  tini_bin='tini-amd64' ;; \
        s390x)   tini_bin='tini-s390x' ;; \
        *) echo >&2 ; echo >&2 "Unsupported architecture $(arch)" ; echo >&2 ; exit 1 ;; \
    esac ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/v0.19.0/${tini_bin} ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/v0.19.0/${tini_bin}.sha256sum ; \
    sha256sum -c ${tini_bin}.sha256sum ; \
    rm ${tini_bin}.sha256sum ; \
    mv ${tini_bin} /bin/tini ; \
    chmod +x /bin/tini

ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN /usr/sbin/groupadd -g 1000 elasticsearch && \
    /usr/sbin/useradd --uid 1000 --gid 1000 -d /usr/share/elasticsearch elasticsearch

WORKDIR /usr/share/elasticsearch

# Set up locale
RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
# Install Temurin 17
 && cd $SOURCE_DIR && mkdir -p /opt/temurin/java && curl -SL -o temurin.tar.gz $TEMURIN_URL \
 && tar -zxf temurin.tar.gz -C /opt/temurin/java --strip-components 1 \
# Build JANSI v2.4.0
 && cd $SOURCE_DIR && git clone https://github.com/fusesource/jansi.git && cd jansi && git checkout jansi-2.4.0 \
 && make clean-native native OS_NAME=Linux OS_ARCH=s390x \
 && mkdir -p $SOURCE_DIR/jansi-jar \
 && cd $SOURCE_DIR/jansi-jar \
 && wget https://repo1.maven.org/maven2/org/fusesource/jansi/jansi/2.4.0/jansi-2.4.0.jar \
 && jar xvf jansi-2.4.0.jar \
 && cd org/fusesource/jansi/internal/native/Linux \
 && mkdir s390x \
 && cp $SOURCE_DIR/jansi/target/native-Linux-s390x/libjansi.so s390x/ \
 && cd $SOURCE_DIR/jansi-jar \
 && jar cvf jansi-2.4.0.jar . \
 && mkdir -p $SOURCE_DIR/.gradle/caches/modules-2/files-2.1/org.fusesource.jansi/jansi/2.4.0/321c614f85f1dea6bb08c1817c60d53b7f3552fd/ \
 && cp jansi-2.4.0.jar $SOURCE_DIR/.gradle/caches/modules-2/files-2.1/org.fusesource.jansi/jansi/2.4.0/321c614f85f1dea6bb08c1817c60d53b7f3552fd/ \
 && export sha256=$(sha256sum $SOURCE_DIR/.gradle/caches/modules-2/files-2.1/org.fusesource.jansi/jansi/2.4.0/321c614f85f1dea6bb08c1817c60d53b7f3552fd/jansi-2.4.0.jar | awk '{print $1}') \
# Download and Build Elasticsearch
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v${ELASTICSEARCH_VER} \
 && curl -o elasticsearch.patch $PATCH_URL  \
 && git apply elasticsearch.patch \
 && sed -i '3146,3146 s|6cd91991323dd7b2fb28ca93d7ac12af5a86a2f53279e2b35827b30313fd0b9f|'"${sha256}"'|g' ${SOURCE_DIR}/elasticsearch/gradle/verification-metadata.xml \
 && ./gradlew :distribution:archives:linux-s390x-tar:assemble --parallel \
# Install Elasticsearch
 && mkdir -p /usr/share/elasticsearch \
 && tar -xzf distribution/archives/linux-s390x-tar/build/distributions/elasticsearch-${ELASTICSEARCH_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/elasticsearch --strip-components 1

# The distribution includes a `config` directory, no need to create it
COPY config/elasticsearch.yml config/
COPY config/log4j2.properties config/log4j2.docker.properties

RUN sed -i -e 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' bin/elasticsearch-env && \
    mkdir data && \
    mv config/log4j2.properties config/log4j2.file.properties && \
    mv config/log4j2.docker.properties config/log4j2.properties && \
    find . -type d -exec chmod 0555 {} + && \
    find . -type f -exec chmod 0444 {} + && \
    chmod 0555 bin/* jdk/bin/* jdk/lib/jspawnhelper && \
    chmod 0775 bin config config/jvm.options.d data logs plugins && \
    find config -type f -exec chmod 0664 {} +

################################################################################
# Build stage 1 (the actual Elasticsearch image):
#
# Copy elasticsearch from stage 0
# Add entrypoint
################################################################################

FROM s390x/ubuntu:20.04

ENV ELASTIC_CONTAINER true

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates netcat p11-kit libvshadow-utils zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/groupadd -g 1000 elasticsearch && \
    adduser --uid 1000 --gid 1000 --home /usr/share/elasticsearch elasticsearch && \
    adduser elasticsearch root && \
    chown -R 0:0 /usr/share/elasticsearch
    
WORKDIR /usr/share/elasticsearch

COPY --from=builder --chown=0:0 /usr/share/elasticsearch /usr/share/elasticsearch
COPY --from=builder --chown=0:0 /bin/tini /bin/tini

ENV PATH /usr/share/elasticsearch/bin:$PATH

COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Update "cacerts" bundle to use Ubuntu's CA certificates (and make sure it
# stays up-to-date with changes to Ubuntu's store)
RUN chmod g=u /etc/passwd && \
    chmod 0555 /usr/local/bin/docker-entrypoint.sh && \
    find / -xdev -perm -4000 -exec chmod ug-s {} + && \
    chmod 0775 /usr/share/elasticsearch && \
    chown elasticsearch bin config config/jvm.options.d data logs plugins

COPY bin/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk

RUN chmod 0555 /etc/ca-certificates/update.d/docker-openjdk && \
    /etc/ca-certificates/update.d/docker-openjdk

EXPOSE 9200 9300

# Our actual entrypoint is `tini`, a minimal but functional init program. It
# calls the entrypoint we provide, while correctly forwarding signals.
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
