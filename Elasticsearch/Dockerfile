# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################################### Dockerfile for Elasticsearch version 7.12.1 ########################################
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

ARG ELASTICSEARCH_VER=7.12.1

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LANG="en_US.UTF-8"
ENV SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/opt/adopt/java
ENV JAVA15_HOME=/opt/adopt/java
ENV PATH=$JAVA_HOME/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Elasticsearch/${ELASTICSEARCH_VER}/patch"
ENV ADOPTJDK_URL="https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_s390x_linux_hotspot_15.0.2_7.tar.gz"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gzip \
    tar \
    wget

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
# Install AdoptOpenJDK 15 (with hotspot)
 && cd $SOURCE_DIR && mkdir -p /opt/adopt/java && curl -SL -o adoptjdk.tar.gz $ADOPTJDK_URL \
 && tar -zxf adoptjdk.tar.gz -C /opt/adopt/java --strip-components 1 \
# Download and Build Elasticsearch
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v${ELASTICSEARCH_VER} \
 && curl -sSL $PATCH_URL/elasticsearch.patch | git apply \
 && ./gradlew :distribution:archives:oss-linux-s390x-tar:assemble --parallel \
# Install Elasticsearch
 && mkdir -p /usr/share/elasticsearch \
 && tar -xzf distribution/archives/oss-linux-s390x-tar/build/distributions/elasticsearch-oss-${ELASTICSEARCH_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/elasticsearch --strip-components 1

# The distribution includes a `config` directory, no need to create it
COPY config/elasticsearch.yml config/log4j2.properties config/

RUN sed -i -e 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' bin/elasticsearch-env && \
    mkdir -p config/jvm.options.d data logs plugins && \
    chmod 0775 config config/jvm.options.d data logs plugins && \
    chmod 0660 config/elasticsearch.yml config/log4j2.properties && \
    find ./jdk -type d -exec chmod 0755 {} + && \
    find . -xdev -perm -4000 -exec chmod ug-s {} + && \
    find . -type f -exec chmod o+r {} +

################################################################################
# Build stage 1 (the actual Elasticsearch image):
#
# Copy elasticsearch from stage 0
# Add entrypoint
################################################################################

FROM s390x/ubuntu:20.04

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV JAVA11_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV PATH=$JAVA_HOME/bin:$PATH
ENV ELASTIC_CONTAINER true

RUN apt-get update && apt-get install -y gzip bzip2 netcat openjdk-11-jdk

WORKDIR /usr/share/elasticsearch
COPY --from=builder --chown=1000:0 /usr/share/elasticsearch /usr/share/elasticsearch
COPY --from=builder --chown=0:0 /bin/tini /bin/tini

RUN /usr/sbin/groupadd -g 1000 elasticsearch && \
    /usr/sbin/useradd -u 1000 -g 1000 -G 0 -d /usr/share/elasticsearch elasticsearch && \
    chmod 0775 /usr/share/elasticsearch && \
    chown -R 1000:0 /usr/share/elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH

COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Replace OpenJDK's built-in CA certificate keystore with the one from the OS
# vendor. The latter is superior in several ways.
# REF: https://github.com/elastic/elasticsearch-docker/issues/171
RUN chmod g=u /etc/passwd && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh && \
    find / -xdev -perm -4000 -exec chmod ug-s {} + && \
    ln -sf /etc/pki/ca-trust/extracted/java/cacerts /usr/share/elasticsearch/jdk/lib/security/cacerts

EXPOSE 9200 9300

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
