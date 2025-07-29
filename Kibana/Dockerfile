# © Copyright IBM Corporation 2017, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 9.0.2 ############################################
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

################################################################################
# Build stage 0 `builder`:
# Build Kibana artifact
################################################################################
FROM redhat/ubi9-minimal:latest AS builder

ARG KIBANA_VER=9.0.2
ARG NODE_JS_VERSION=20.18.2

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set Environment Variable
ENV SOURCE_ROOT=/home/nonroot
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV PATH=/usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x/bin:/usr/share/kibana/bin:$JAVA_HOME/bin:$SOURCE_ROOT/bazel/output/:$PATH
ENV NODE_OPTIONS="--max_old_space_size=4096"

RUN microdnf install -y findutils tar gzip sudo dnf which \
  && useradd -s /bin/bash -d /home/nonroot/ -m -G wheel nonroot \
  && echo "nonroot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Kibana cannot be built as root
USER nonroot
RUN cd $SOURCE_ROOT \
  && curl -o build_kibana.sh https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/$KIBANA_VER/build_kibana.sh \
  && bash build_kibana.sh -y

USER root
WORKDIR /usr/share/kibana
RUN cd $SOURCE_ROOT/kibana \
  && mkdir -p /usr/share/kibana/ \
  && tar xzf target/kibana-${KIBANA_VER}-linux-s390x.tar.gz -C /usr/share/kibana --strip-components 1

# Ensure that group permissions are the same as user permissions.
# This will help when relying on GID-0 to run Kibana, rather than UID-1000.
# OpenShift does this, for example.
# REF: https://docs.openshift.org/latest/creating_images/guidelines.html
RUN chmod -R g=u /usr/share/kibana

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
RUN mkdir -p /usr/share/fonts/local && \
  curl --retry 8 -S -L -o /usr/share/fonts/local/NotoSansCJK-Regular.ttc https://github.com/googlefonts/noto-cjk/raw/NotoSansV2.001/NotoSansCJK-Regular.ttc && \
  echo "5dcd1c336cc9344cb77c03a0cd8982ca8a7dc97d620fd6c9c434e02dcb1ceeb3  /usr/share/fonts/local/NotoSansCJK-Regular.ttc" | sha256sum -c -

################################################################################
# Build stage 1 (the actual Kibana image):
#
# Copy kibana from stage 0
# Add entrypoint
################################################################################
FROM redhat/ubi9-minimal:latest
EXPOSE 5601

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN for iter in {1..10}; do \
      microdnf update --setopt=tsflags=nodocs -y && \
      microdnf install --setopt=tsflags=nodocs -y \
      fontconfig liberation-fonts-common freetype shadow-utils nss findutils && \
      microdnf clean all && exit_code=0 && break || exit_code=$? && echo "microdnf error: retry $iter in 10s" && \
      sleep 10; \
    done; \
    (exit $exit_code)

# Bring in Kibana from the initial stage.
COPY --from=builder --chown=1000:0 /usr/share/kibana /usr/share/kibana
COPY --from=builder --chown=0:0 /bin/tini /bin/tini
# Load reporting fonts
COPY --from=builder --chown=0:0 /usr/share/fonts/local/NotoSansCJK-Regular.ttc /usr/share/fonts/local/NotoSansCJK-Regular.ttc
RUN fc-cache -v
WORKDIR /usr/share/kibana
RUN ln -s /usr/share/kibana /opt/kibana

ENV ELASTIC_CONTAINER=true
ENV PATH=/usr/share/kibana/bin:$PATH

# Set some Kibana configuration defaults.
COPY --chown=1000:0 config/kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY bin/kibana-docker /usr/local/bin/

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

LABEL org.label-schema.license="Elastic License" \
      org.label-schema.name="Kibana" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-url="https://github.com/elastic/kibana" \
      org.label-schema.version="9.0.2-SNAPSHOT" \
      org.opencontainers.image.documentation="https://www.elastic.co/guide/en/kibana/reference/index.html" \
      org.opencontainers.image.licenses="Elastic License" \
      org.opencontainers.image.source="https://github.com/elastic/kibana" \
      org.opencontainers.image.title="Kibana" \
      org.opencontainers.image.version="9.0.2-SNAPSHOT"

ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/kibana-docker"]

USER 1000