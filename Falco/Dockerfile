# © Copyright IBM Corporation 2026
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Falco 0.43.1 ####################
#
# This Dockerfile builds a basic installation of Falco.
#
# Falco is a behavioral activity monitor designed to detect anomalous activity in your applications.
# Falco lets you continuously monitor and detect container, application, host, and network activity.
# All in one place, from one source of data, with one set of rules.
#
# docker build -t <image_name> .
#
# To start a container with Falco image.
# docker run -i -t --privileged --name <container_name> -v /var/run/docker.sock:/host/var/run/docker.sock -v /proc:/host/proc:ro  -v /etc:/host/etc:ro -v /sys/kernel/tracing:/sys/kernel/tracing:ro <image_name>
#
# For example
# docker run -i -t --privileged --name falco -v /var/run/docker.sock:/host/var/run/docker.sock -v /proc:/host/proc:ro  -v /etc:/host/etc:ro -v /sys/kernel/tracing:/sys/kernel/tracing:ro falco:latest
#
#
###########################################################################
# Base image
FROM s390x/ubuntu:22.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
WORKDIR /home/root/
ARG VERSION=0.43.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl ca-certificates \
        build-essential clang llvm cmake make \
        libssl-dev libyaml-dev libncurses-dev \
        libc-ares-dev libprotobuf-dev protobuf-compiler \
        libjq-dev libyaml-cpp-dev libcurl4-openssl-dev libelf-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl  -SLO https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Falco/${VERSION}/build_falco.sh \
    && chmod +x build_falco.sh \
    && sed -i 's/sudo //g' build_falco.sh \
    && sed -i 's/-DBUILD_DRIVER=ON/-DBUILD_DRIVER=OFF/g' build_falco.sh \
    && sed -i 's/kernel-devel-$(uname -r) //g' build_falco.sh \
    && sed -i 's/linux-headers-$(uname -r) //g' build_falco.sh \
    && sed -i 's/linux-tools-$(uname -r) //g' build_falco.sh \
    && sed -i '/insmod/d' build_falco.sh \
    && sed -i '/rmmod/d' build_falco.sh \
    && bash build_falco.sh -y

RUN strip /usr/bin/falco || true

FROM s390x/ubuntu:22.04

LABEL RUN="docker run -i -t --privileged --name NAME -v /var/run/docker.sock:/host/var/run/docker.sock -v /proc:/host/proc:ro  -v /etc:/host/etc:ro -v /sys/kernel/tracing:/sys/kernel/tracing:ro IMAGE"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Copy only required runtime files
COPY --from=builder /usr/bin/falco /usr/bin/falco
COPY --from=builder /etc/falco /etc/falco
COPY --from=builder /usr/share/falco /usr/share/falco

# Enable ISO 8601 timestamps
RUN sed -i 's/time_format_iso_8601: false/time_format_iso_8601: true/' \
    /etc/falco/falco.yaml

CMD ["/usr/bin/falco"]
