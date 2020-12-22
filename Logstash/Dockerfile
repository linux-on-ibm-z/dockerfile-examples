# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Logstash version 7.10.0 #####################################################
#
# This Dockerfile builds a basic installation of Logstash
#
# Logstash is a tool for managing events and logs. When used generically the term
# encompasses a larger system of log collection, processing, storage and searching activities.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Logstash using below command
# docker run --name <container name> -d <logstash_image>
#
# Logstash can be started with custom configuration by changing the pipeline/default.conf file
###############################################################################################################


FROM golang AS builder

ADD env2yaml/env2yaml.go /go/
RUN go get gopkg.in/yaml.v2 && go build /go/env2yaml.go

FROM s390x/ubuntu:20.04

ARG LOGSTASH_VER=7.10.0

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV LD_LIBRARY_PATH=/usr/lib/s390x-linux-gnu/jni/:$LD_LIBRARY_PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
# Install Dependencies
RUN apt-get update && apt-get install -y openjdk-11-jdk locales \
    libjffi-jni \
    make \
    tar \
    wget \
    curl \
    gzip

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 logstash && \
    /usr/sbin/useradd --uid 1000 --gid 1000 \
      --home-dir /usr/share/logstash --no-create-home \
      logstash

# Add Logstash itself.
RUN curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-oss-${LOGSTASH_VER}-linux-aarch64.tar.gz  | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-${LOGSTASH_VER} /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash && \
    # Cleanup Cache data , unused packages and source files
    apt-get remove -y make wget curl && apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/share/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$JAVA_HOME/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/pipelines.yml config/pipelines.yml
ADD config/logstash-oss.yml config/logstash.yml
ADD config/log4j2.properties config/
ADD pipeline/default.conf pipeline/logstash.conf
RUN chown --recursive logstash:root config/ pipeline/

# Ensure Logstash gets a UTF-8 locale by default.
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER 1000

COPY --from=builder /go/env2yaml /usr/local/bin/

EXPOSE 9600 5044

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
