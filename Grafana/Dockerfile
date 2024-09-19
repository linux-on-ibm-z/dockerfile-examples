# syntax=docker/dockerfile:1
# Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Grafana 11.2.0 ############################################
#
# This Dockerfile builds a basic installation of Grafana.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Grafana service using this image, use following command:
# docker run --name <container name> -p <port>:3000 -d <image name>
#
# To start the Grafana service by providing configuration
# docker run --name <container_name> -v <path_to_grafana_config_file>:/usr/share/grafana/conf/custom.ini -p <port>:3000 -d <image_name>
# More information in the grafana configuration documentation: http://docs.grafana.org/installation/configuration/
################################################################################################################

ARG GRAFANA_VERSION=11.2.0

ARG BASE_IMAGE=ubuntu:22.04
ARG GO_IMAGE=golang:1.22.4

ARG GO_SRC=go-builder
ARG JS_SRC=tgz-builder

FROM ${GO_IMAGE} as go-src-builder

ARG GRAFANA_VERSION

WORKDIR /tmp

RUN git clone --depth=1 --single-branch -b v"${GRAFANA_VERSION}" https://github.com/grafana/grafana.git

FROM ${GO_IMAGE} as go-builder

ARG COMMIT_SHA=""
ARG BUILD_BRANCH=""
ARG GO_BUILD_TAGS="oss"
ARG WIRE_TAGS="oss"
ARG BINGO="true"

RUN if grep -i -q alpine /etc/issue; then \
      apk add --no-cache \
          # This is required to allow building on arm64 due to https://github.com/golang/go/issues/22040
          binutils-gold \
          # Install build dependencies
          gcc g++ make git; \
    fi

WORKDIR /tmp/grafana

COPY --from=go-src-builder /tmp/grafana/go.* ./
COPY --from=go-src-builder /tmp/grafana/.bingo .bingo

# Include vendored dependencies
COPY --from=go-src-builder /tmp/grafana/pkg/util/xorm/go.* pkg/util/xorm/
COPY --from=go-src-builder /tmp/grafana/pkg/apiserver/go.* pkg/apiserver/
COPY --from=go-src-builder /tmp/grafana/pkg/apimachinery/go.* pkg/apimachinery/
COPY --from=go-src-builder /tmp/grafana/pkg/build/go.* pkg/build/
COPY --from=go-src-builder /tmp/grafana/pkg/build/wire/go.* pkg/build/wire/
COPY --from=go-src-builder /tmp/grafana/pkg/promlib/go.* pkg/promlib/
COPY --from=go-src-builder /tmp/grafana/pkg/storage/unified/resource/go.* pkg/storage/unified/resource/
COPY --from=go-src-builder /tmp/grafana/pkg/semconv/go.* pkg/semconv/

RUN go mod download
RUN if [[ "$BINGO" = "true" ]]; then \
      go install github.com/bwplotka/bingo@latest && \
      bingo get -v; \
    fi

COPY --from=go-src-builder /tmp/grafana/embed.go /tmp/grafana/Makefile /tmp/grafana/build.go /tmp/grafana/package.json ./
COPY --from=go-src-builder /tmp/grafana/cue.mod cue.mod
COPY --from=go-src-builder /tmp/grafana/kinds kinds
COPY --from=go-src-builder /tmp/grafana/local local
COPY --from=go-src-builder /tmp/grafana/packages/grafana-schema packages/grafana-schema
COPY --from=go-src-builder /tmp/grafana/public/app/plugins public/app/plugins
COPY --from=go-src-builder /tmp/grafana/public/api-merged.json public/api-merged.json
COPY --from=go-src-builder /tmp/grafana/pkg pkg
COPY --from=go-src-builder /tmp/grafana/scripts scripts
COPY --from=go-src-builder /tmp/grafana/conf conf
COPY --from=go-src-builder /tmp/grafana/.github .github

ENV COMMIT_SHA=${COMMIT_SHA}
ENV BUILD_BRANCH=${BUILD_BRANCH}

RUN make build-go GO_BUILD_TAGS=${GO_BUILD_TAGS} WIRE_TAGS=${WIRE_TAGS}

FROM ${BASE_IMAGE} as tgz-builder

ARG GRAFANA_VERSION

WORKDIR /tmp/grafana

RUN if grep -i -q ubuntu /etc/issue; then \
        DEBIAN_FRONTEND=noninteractive && \
        apt-get update && \
        apt-get install -y wget && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo 'ERROR: Unsupported base image' && /bin/false; \
    fi && \
    wget -O /tmp/grafana.tar.gz https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz

# add -v to make tar print every file it extracts
RUN tar x -z -f /tmp/grafana.tar.gz --strip-components=1

# helpers for COPY --from
FROM ${GO_SRC} as go-src
FROM ${JS_SRC} as js-src

# Final stage
FROM ${BASE_IMAGE}

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG GF_UID="472"
ARG GF_GID="0"

ENV PATH="/usr/share/grafana/bin:$PATH" \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

# Install dependencies
RUN if grep -i -q alpine /etc/issue; then \
      apk add --no-cache ca-certificates bash curl tzdata musl-utils && \
      apk info -vv | sort; \
    elif grep -i -q ubuntu /etc/issue; then \
      DEBIAN_FRONTEND=noninteractive && \
      apt-get update && \
      apt-get install -y ca-certificates curl tzdata musl && \
      apt-get autoremove -y && \
      rm -rf /var/lib/apt/lists/*; \
    else \
      echo 'ERROR: Unsupported base image' && /bin/false; \
    fi

# glibc support for alpine x86_64 only
RUN if grep -i -q alpine /etc/issue && [ `arch` = "x86_64" ]; then \
      wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
      wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk \
        -O /tmp/glibc-2.35-r0.apk && \
      wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-bin-2.35-r0.apk \
        -O /tmp/glibc-bin-2.35-r0.apk && \
      apk add --force-overwrite --no-cache /tmp/glibc-2.35-r0.apk /tmp/glibc-bin-2.35-r0.apk && \
      rm -f /lib64/ld-linux-x86-64.so.2 && \
      ln -s /usr/glibc-compat/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
      rm -f /tmp/glibc-2.35-r0.apk && \
      rm -f /tmp/glibc-bin-2.35-r0.apk && \
      rm -f /lib/ld-linux-x86-64.so.2 && \
      rm -f /etc/ld.so.cache; \
    fi

COPY --from=go-src /tmp/grafana/conf ./conf

RUN if [ ! $(getent group "$GF_GID") ]; then \
      if grep -i -q alpine /etc/issue; then \
        addgroup -S -g $GF_GID grafana; \
      else \
        addgroup --system --gid $GF_GID grafana; \
      fi; \
    fi && \
    GF_GID_NAME=$(getent group $GF_GID | cut -d':' -f1) && \
    mkdir -p "$GF_PATHS_HOME/.aws" && \
    if grep -i -q alpine /etc/issue; then \
      adduser -S -u $GF_UID -G "$GF_GID_NAME" grafana; \
    else \
      adduser --system --uid $GF_UID --ingroup "$GF_GID_NAME" grafana; \
    fi && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_PROVISIONING/notifiers" \
             "$GF_PATHS_PROVISIONING/plugins" \
             "$GF_PATHS_PROVISIONING/access-control" \
             "$GF_PATHS_PROVISIONING/alerting" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp conf/sample.ini "$GF_PATHS_CONFIG" && \
    cp conf/ldap.toml /etc/grafana/ldap.toml && \
    chown -R "grafana:$GF_GID_NAME" "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" && \
    chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"

COPY --from=go-src /tmp/grafana/bin/grafana* /tmp/grafana/bin/*/grafana* ./bin/
COPY --from=js-src /tmp/grafana/public ./public
COPY --from=js-src /tmp/grafana/LICENSE ./

EXPOSE 3000

ARG RUN_SH=./run.sh

COPY ${RUN_SH} /run.sh

RUN chmod +x /run.sh

USER "$GF_UID"
ENTRYPOINT [ "/run.sh" ]
