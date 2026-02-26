# © Copyright IBM Corporation 2026
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Falco 0.43.0 ####################
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
# docker run --interactive --privileged --tty --name <container_name> --volume /sys/kernel/tracing:/sys/kernel/tracing:ro --volume /proc:/host/proc:ro --volume /etc:/host/etc:ro <image_name> falco -o engine.kind=modern_ebpf
#
# For example
# docker run --interactive --privileged --tty --name falco --volume /sys/kernel/tracing:/sys/kernel/tracing:ro --volume /proc:/host/proc:ro --volume /etc:/host/etc:ro <image_name> falco -o engine.kind=modern_ebpf
#
#
###########################################################################
# Base image
FROM s390x/ubuntu:22.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
WORKDIR /home/root/
ARG VERSION=0.43.0
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl ca-certificates \
        build-essential clang llvm cmake make \
        libssl-dev libyaml-dev libncurses-dev \
        libc-ares-dev libprotobuf-dev protobuf-compiler \
        libjq-dev libyaml-cpp-dev libcurl4-openssl-dev libelf-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and patch build script 
RUN curl  -SLO https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Falco/${VERSION}/build_falco.sh \
    && chmod +x build_falco.sh \
    && sed -i 's/sudo //g' build_falco.sh \
    && sed -i '/insmod/d' build_falco.sh \
    && sed -i '/rmmod/d' build_falco.sh \
    && bash build_falco.sh -y

RUN strip /usr/bin/falco || true

FROM s390x/ubuntu:22.04

LABEL RUN="docker run --interactive --privileged --tty --name NAME --volume /sys/kernel/tracing:/sys/kernel/tracing:ro --volume /proc:/host/proc:ro --volume /etc:/host/etc:ro IMAGE falco -o engine.kind=modern_ebpf"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3 \
        libyaml-0-2 \
        libncurses6 \
        libelf1 \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Copy only required runtime files
COPY --from=builder /usr/bin/falco /usr/bin/falco
COPY --from=builder /etc/falco /etc/falco
COPY --from=builder /usr/share/falco /usr/share/falco
COPY --from=builder /etc/falcoctl /etc/falcoctl

# Enable ISO 8601 timestamps
RUN sed -i 's/time_format_iso_8601: false/time_format_iso_8601: true/' \
    /etc/falco/falco.yaml

# Add minimal entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/falco"]
