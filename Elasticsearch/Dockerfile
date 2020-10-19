# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################################### Dockerfile for Elasticsearch version 7.9.1 ########################################
#
# This Dockerfile builds a basic installation of Elasticsearch.
#
# Elasticsearch is a search server based on Lucene. It provides a distributed, multitenant-capable
# full-text search engine with an HTTP web interface and schema-free JSON documents.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Elasticsearch container using the below command
# docker run --name <container_name> -p 9200:9200 -d <image_name>
#
# Start Elastic search with configuration file
# For ex. docker run --name <container_name> -v <path_on_host>/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -p <port>:9200 -d <image_name>
#
##############################################################################################################
################################################################################
# Build stage 0 `builder`:
# Extract elasticsearch artifact
# Set gid=0 and make group perms==owner perms
################################################################################

FROM s390x/ubuntu:18.04 AS builder

ARG ELASTICSEARCH_VER=7.9.1

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LANG="en_US.UTF-8"
ENV SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/usr/share/jdk-11.0.8+10
ENV JAVA11_HOME=/usr/share/jdk-11.0.8+10
ENV PATH=$JAVA_HOME/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Elasticsearch/${ELASTICSEARCH_VER}/patch"

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
    \
    tini_bin="" ; \
    case "$(arch)" in \
        aarch64) tini_bin='tini-arm64' ;; \
        x86_64)  tini_bin='tini-amd64' ;; \
		s390x)   tini_bin='tini-s390x' ;; \
        *) echo >&2 ; echo >&2 "Unsupported architecture $(arch)" ; echo >&2 ; exit 1 ;; \
    esac ; \
    curl --retry 8 -S -L -O https://github.com/krallin/tini/releases/download/v0.19.0/${tini_bin} ; \
    curl --retry 8 -S -L -O https://github.com/krallin/tini/releases/download/v0.19.0/${tini_bin}.sha256sum ; \
    sha256sum -c ${tini_bin}.sha256sum ; \
    rm ${tini_bin}.sha256sum ; \
    mv ${tini_bin} /tini ; \
    chmod +x /tini

ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN /usr/sbin/groupadd -g 1000 elasticsearch && \
    /usr/sbin/useradd --uid 1000 --gid 1000 -d /usr/share/elasticsearch elasticsearch

WORKDIR /usr/share/elasticsearch
	  
# Set up locale
RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
# Download AdoptOpenJDK 11
 && cd $SOURCE_DIR \
 && curl -SLO https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10_openj9-0.21.0/OpenJDK11U-jdk_s390x_linux_openj9_11.0.8_10_openj9-0.21.0.tar.gz \
 && tar -C /usr/share/ -xzf OpenJDK11U-jdk_s390x_linux_openj9_11.0.8_10_openj9-0.21.0.tar.gz \
# Download and Build Elasticsearch
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v${ELASTICSEARCH_VER} \
 && wget $PATCH_URL/build.gradle  -P $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/archives/oss-linux-s390x-tar && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/archives/oss-linux-s390x-tar \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-deb && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-deb \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-deb && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-deb \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-rpm && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-rpm \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-rpm && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-rpm \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-export && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-export \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-export && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-export \
 && wget $PATCH_URL/docker_build_context_build.gradle -P $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context \
 && mv $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context/docker_build_context_build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context/build.gradle \
 && wget $PATCH_URL/oss_docker_build_context_build.gradle -P $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context \
 && mv $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context/oss_docker_build_context_build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context/build.gradle \
 && wget -O - $PATCH_URL/diff.patch | git apply \
 && ./gradlew :distribution:archives:oss-linux-s390x-tar:assemble --parallel \
# Create distributions as deb, rpm and docker
 && ./gradlew :distribution:docker:oss-docker-s390x-build-context:assemble \ 
# Install Elasticsearch
 && mkdir -p /usr/share/elasticsearch \
 && tar -xzf distribution/archives/oss-linux-s390x-tar/build/distributions/elasticsearch-oss-${ELASTICSEARCH_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/elasticsearch --strip-components 1

RUN sed -i -e 's/ES_DISTRIBUTION_TYPE=tar/ES_DISTRIBUTION_TYPE=docker/' /usr/share/elasticsearch/bin/elasticsearch-env
RUN mkdir -p config config/jvm.options.d data logs
RUN chmod 0775 config config/jvm.options.d data logs
COPY config/elasticsearch.yml config/log4j2.properties config/
RUN chmod 0660 config/elasticsearch.yml config/log4j2.properties

################################################################################
# Build stage 1 (the actual elasticsearch image):
# Copy elasticsearch from stage 0
# Add entrypoint
################################################################################

FROM s390x/ubuntu:18.04

ENV ELASTIC_CONTAINER true

COPY --from=builder /tini /tini
	
RUN apt-get update && apt-get install -y gzip bzip2 netcat

RUN /usr/sbin/groupadd -g 1000 elasticsearch && \
    /usr/sbin/useradd --uid 1000 --gid 1000 -G 0 -d /usr/share/elasticsearch elasticsearch
    
WORKDIR /usr/share/elasticsearch
COPY --from=builder --chown=1000:0 /usr/share/elasticsearch /usr/share/elasticsearch

RUN chmod 0775 /usr/share/elasticsearch && \
    chgrp 0 /usr/share/elasticsearch

# Replace OpenJDK's built-in CA certificate keystore with the one from the OS
# vendor. The latter is superior in several ways.
# REF: https://github.com/elastic/elasticsearch-docker/issues/171
RUN ln -sf /etc/pki/ca-trust/extracted/java/cacerts /usr/share/elasticsearch/jdk/lib/security/cacerts

ENV PATH /usr/share/elasticsearch/bin:$PATH

COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod g=u /etc/passwd && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh

# Ensure that there are no files with setuid or setgid, in order to mitigate "stackclash" attacks.
RUN find / -xdev -perm -4000 -exec chmod ug-s {} +

EXPOSE 9200 9300

ENTRYPOINT ["/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
# Dummy overridable parameter parsed by entrypoint
CMD ["eswrapper"]

################################################################################
# End of multi-stage Dockerfile
################################################################################
