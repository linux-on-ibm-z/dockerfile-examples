# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Logstash #####################################################
#
# This Dockerfile builds a basic installation of Logstash
#
# Logstash is a tool for managing events and logs. When used generically the term
# encompasses a larger system of log collection, processing, storage and searching activities.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> --file Logstash.dockerfile .
#
# Start Logstash using below command
# docker run --name <container name> -d <logstash_image>
#
# Logstash can be started with custom configuration by changing the pipeline/default.conf file
###############################################################################################################

FROM redhat/ubi9-minimal:latest

ARG LOGSTASH_VER=9.4.2

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source)"

ENV ELASTIC_CONTAINER=true
ENV LS_JAVA_HOME=/opt/temurin21
ENV PATH=/usr/share/logstash/bin:$LS_JAVA_HOME/bin:$PATH
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

WORKDIR /usr/share

# Install packages
RUN microdnf install -y \
      procps \
      findutils \
      tar \
      gzip \
      openssl \
      shadow-utils && \
    microdnf clean all

# Provide a non-root user
# Install Temurin JDK for s390x
# Install Logstash and set permissions
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home "/usr/share/logstash" \
      --no-create-home \
      logstash && \
    mkdir -p /opt/temurin21 && \
    curl --fail --location \
      https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.11%2B10/OpenJDK21U-jdk_s390x_linux_hotspot_21.0.11_10.tar.gz \
      --output /tmp/temurin21.tar.gz && \
    tar -zxf /tmp/temurin21.tar.gz \
      -C /opt/temurin21 \
      --strip-components=1 && \
    rm -f /tmp/temurin21.tar.gz && \
    curl --fail --location \
      --output logstash.tar.gz \
      https://artifacts.elastic.co/downloads/logstash/logstash-oss-${LOGSTASH_VER}-linux-aarch64.tar.gz && \
    tar -zxf logstash.tar.gz -C /usr/share && \
    rm logstash.tar.gz && \
    mv /usr/share/logstash-${LOGSTASH_VER} /usr/share/logstash && \
    rm -rf /usr/share/logstash/jdk && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash

RUN curl --fail --location \
      https://github.com/elastic/dockerfiles/archive/refs/tags/v${LOGSTASH_VER}.tar.gz \
      -o /tmp/dockerfiles.tar.gz && \
    tar -xzf /tmp/dockerfiles.tar.gz -C /tmp && \
    mkdir -p /usr/share/logstash/env2yaml/classes && \
    mkdir -p /usr/share/logstash/env2yaml/lib && \
    cp -r /tmp/dockerfiles-${LOGSTASH_VER}/logstash/env2yaml/classes/* \
        /usr/share/logstash/env2yaml/classes/ && \
    cp -r /tmp/dockerfiles-${LOGSTASH_VER}/logstash/env2yaml/lib/* \
        /usr/share/logstash/env2yaml/lib/ && \
    install -m 0755 /tmp/dockerfiles-${LOGSTASH_VER}/logstash/env2yaml/env2yaml \
        /usr/local/bin/env2yaml && \
    rm -rf /tmp/dockerfiles*

COPY --chown=logstash:root \
    config/pipelines.yml \
    config/log4j2.properties \
    config/log4j2.file.properties \
    /usr/share/logstash/config/

COPY --chown=logstash:root \
    config/logstash-oss.yml \
    /usr/share/logstash/config/logstash.yml

COPY --chown=logstash:root \
    pipeline/default.conf \
    /usr/share/logstash/pipeline/logstash.conf

COPY --chmod=0755 \
    bin/docker-entrypoint \
    /usr/local/bin/

WORKDIR /usr/share/logstash

USER 1000

EXPOSE 9600 5044

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
