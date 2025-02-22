# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 8.16.1 ############################################
#
# This Dockerfile builds a basic installation of Kibana.
#
# Kibana is an open source data visualization plugin for Elasticsearch.
# It provides visualization capabilities on top of the content indexed on an Elasticsearch cluster.
# Users can create bar, line and scatter plots, or pie charts and maps on top of large volumes of data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# In the given example, Kibana will attach to a user defined network (useful
# for connecting to other services (e.g. Elasticsearch)). If network has not yet
# been created, this can be done with the following command:
#
# $ docker network create somenetwork
#
# Note: In this example, Kibana is using the default configuration and expects
# to connect to a running Elasticsearch instance at http://localhost:9200
#
# Run Kibana:
#
# $ docker run -d --name kibana --net somenetwork -p 5601:5601 kibana:tag
#
# Kibana can be accessed by browser via http://localhost:5601 or http://host-ip:5601
#
##############################################################################################################
FROM ubuntu:20.04 AS builder

ARG KIBANA_VER=8.16.1
ARG NODE_JS_VERSION=20.15.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set Environment Variable
ENV SOURCE_ROOT=/home/nonroot
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV PATH=/usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x/bin:/usr/share/kibana/bin:$JAVA_HOME/bin:$SOURCE_ROOT/bazel/output/:$PATH
ENV USE_BAZEL_VERSION=$SOURCE_ROOT/bazel/output/bazel
ENV NODE_OPTIONS="--max_old_space_size=4096"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yq \
    sudo \
    git \
    tzdata \
    curl \
 && useradd -s /bin/bash -d /home/nonroot/ -m -G sudo nonroot \
 && echo "nonroot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Kibana cannot be built as root
USER nonroot

RUN cd $SOURCE_ROOT \
 && curl -o build_kibana.sh https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/$KIBANA_VER/build_kibana.sh \
 && bash build_kibana.sh -y

USER root
RUN cd $SOURCE_ROOT/kibana \
 && mkdir -p /usr/share/kibana/ \
 && tar xzf target/kibana-${KIBANA_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/kibana --strip-components 1

WORKDIR /usr/share/kibana
RUN chmod -R g=u /usr/share/kibana

# Add an init process, check the checksum to make sure it's a match
FROM ubuntu:20.04
EXPOSE 5601

RUN for iter in {1..10}; do \
      export DEBIAN_FRONTEND=noninteractive && \
      apt-get update  && \
      apt-get upgrade -y  && \
      apt-get install -y --no-install-recommends \
       fontconfig fonts-liberation libnss3 libfontconfig1 ca-certificates curl && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* && exit_code=0 && break || exit_code=$? && echo "apt-get error: retry $iter in 10s" && \
      sleep 10; \
    done; \
    (exit $exit_code)

# Add an init process, check the checksum to make sure it's a match
RUN set -e ; \
  TINI_VERSION='v0.19.0' ; \
  TINI_BIN='tini-s390x' ; \
  curl --retry 8 -S -L -O "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}" ; \
  curl --retry 8 -S -L -O "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}.sha256sum" ; \
  sha256sum -c "${TINI_BIN}.sha256sum" ; \
  rm "${TINI_BIN}.sha256sum" ; \
  mv "${TINI_BIN}" /bin/tini ; \
  chmod +x /bin/tini

RUN mkdir /usr/share/fonts/local
RUN curl --retry 8 -S -L -o /usr/share/fonts/local/NotoSansCJK-Regular.ttc https://github.com/googlefonts/noto-cjk/raw/NotoSansV2.001/NotoSansCJK-Regular.ttc
RUN echo "5dcd1c336cc9344cb77c03a0cd8982ca8a7dc97d620fd6c9c434e02dcb1ceeb3  /usr/share/fonts/local/NotoSansCJK-Regular.ttc" | sha256sum -c -
RUN fc-cache -v

# Bring in Kibana from the initial stage.
COPY --from=builder --chown=1000:0 /usr/share/kibana /usr/share/kibana
WORKDIR /usr/share/kibana
RUN ln -s /usr/share/kibana /opt/kibana

ENV ELASTIC_CONTAINER=true
ENV PATH=/usr/share/kibana/bin:$PATH

# Set some Kibana configuration defaults.
COPY --chown=1000:0 config/kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY --chown=1000:0 bin/kibana-docker /usr/local/bin/

# Ensure gid 0 write permissions for OpenShift.
RUN chmod g+ws /usr/share/kibana && \
    chmod +x /usr/local/bin/kibana-docker && \
    find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

# Remove the suid bit everywhere to mitigate "Stack Clash"
RUN find / -xdev -perm -4000 -exec chmod u-s {} +

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 kibana && \
    useradd --uid 1000 --gid 1000 -G 0 \
      --home-dir /usr/share/kibana --no-create-home \
      kibana

ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/kibana-docker"]

USER kibana
