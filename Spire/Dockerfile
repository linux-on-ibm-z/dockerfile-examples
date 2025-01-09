# © Copyright IBM Corporation 2024,2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################### Dockerfile for SPIRE version 1.11.1 ########################
#
# SPIRE (the SPIFFE Runtime Environment) is a toolchain of APIs for establishing trust between software systems across a wide variety of hosting platforms.
# SPIRE exposes the SPIFFE Workload API,which can attest running software systems and issue SPIFFE IDs and SVIDs to them.
#
# Run below commands from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
#
# To build SPIRE server:
# docker build --target spire-server -t <image_name>  .
#
# To build SPIRE oidc-discovery-provider:
# docker build --target oidc-discovery-provider  -t <image_name> .
#
# To build SPIRE agent:
# docker build --target spire-agent -t <image_name>  .
#
# To run the spire-server image, use the below command by providing the path for custom server config or use default server config \
# by cloning the files from SPIRE repository given below.
# git clone https://github.com/spiffe/spire.git
#
# docker run --name <container_name> --user 1000:1000 \
# -p 8081:8081 -v /path/to/server/config:/etc/spire/server \
# -d <image_name> -config /etc/spire/server/server.conf
#
# More information on running Docker images with provided configuration can be found here:
# https://github.com/spiffe/spire/blob/main/doc/docker_images.md
#
#####################################################################

# Build stage
ARG goversion=1.23.2
# Use alpine3.18 until go-sqlite works in 3.19
FROM --platform=${BUILDPLATFORM} golang:${goversion}-alpine3.20 as base
WORKDIR /spire
RUN apk --no-cache --update add file bash clang lld pkgconfig git wget make
RUN wget https://raw.githubusercontent.com/spiffe/spire/v1.11.1/go.mod && \
wget https://raw.githubusercontent.com/spiffe/spire/v1.11.1/go.sum

# https://go.dev/ref/mod#module-cache
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .

# xx is a helper for cross-compilation
# when bumping to a new version analyze the new version for security issues
# then use crane to lookup the digest of that version so we are immutable
# crane digest tonistiigi/xx:1.3.0
FROM --platform=$BUILDPLATFORM tonistiigi/xx@sha256:904fe94f236d36d65aeb5a2462f88f2c537b8360475f6342e7599194f291fb7e AS xx

FROM --platform=${BUILDPLATFORM} base as builder
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG VERSION=1.11.1
COPY --link --from=xx / /

RUN xx-go --wrap
RUN set -e ; xx-apk --no-cache --update add build-base musl-dev libseccomp-dev openssl-dev wget git make gcc curl
ENV CGO_ENABLED=1
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Spire/${VERSION}/patch"
# Build Spire
RUN git clone -b v${VERSION} https://github.com/spiffe/spire.git \
&& cd spire \
&& curl -sSL $PATCH_URL/spire.patch | git apply - \
&& make build-static

FROM --platform=${BUILDPLATFORM} scratch AS spire-base
COPY --link --from=builder --chown=root:root --chmod=755 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /opt/spire
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Preparation environment for setting up directories
FROM alpine as prep-spire-server
RUN mkdir -p /spireroot/opt/spire/bin \
    /spireroot/etc/spire/server \
    /spireroot/run/spire/server/private \
    /spireroot/tmp/spire-server/private \
    /spireroot/var/lib/spire/server

FROM alpine as prep-spire-agent
RUN mkdir -p /spireroot/opt/spire/bin \
    /spireroot/etc/spire/agent \
    /spireroot/run/spire/agent/public \
    /spireroot/tmp/spire-agent/public \
    /spireroot/var/lib/spire/agent

# For users that wish to run SPIRE containers with a specific uid and gid, the
# spireuid and spiregid arguments are provided. The default paths that SPIRE
# will try to read from, write to, and create at runtime are given the
# corresponding file ownership/permissions at build time.
# A default non-root user is defined for SPIRE Server and the OIDC Discovery
# Provider. The SPIRE Agent image runs as root by default to facilitate the
# sharing of the agent socket in Kubernetes environments.

# SPIRE Server
FROM spire-base AS spire-server
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG spireuid=1000
ARG spiregid=1000
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/spire-server", "run"]
COPY --link --from=prep-spire-server --chown=${spireuid}:${spiregid} --chmod=755 /spireroot /
COPY --link --from=builder --chown=${spireuid}:${spiregid} --chmod=755 /spire/spire/bin/static/spire-server /opt/spire/bin/

# SPIRE Agent
FROM spire-base AS spire-agent
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG spireuid=0
ARG spiregid=0
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/spire-agent", "run"]
COPY --link --from=prep-spire-agent --chown=${spireuid}:${spiregid} --chmod=755 /spireroot /
COPY --link --from=builder --chown=${spireuid}:${spiregid} --chmod=755 /spire/spire/bin/static/spire-agent /opt/spire/bin/
# OIDC Discovery Provider
FROM spire-base AS oidc-discovery-provider
ARG spireuid=1000
ARG spiregid=1000
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/oidc-discovery-provider"]
COPY --link --from=builder --chown=${spireuid}:${spiregid} --chmod=755 /spire/spire/bin/static/oidc-discovery-provider /opt/spire/bin/
