# © Copyright IBM Corporation 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################### Dockerfile for SPIRE version 1.9.1 ########################
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
FROM ubuntu:22.04 as base
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
WORKDIR /spire
ARG VERSION=1.9.1
ENV DEBIAN_FRONTEND noninteractive
ENV SOURCE_ROOT=/tmp
ENV CGO_ENABLED=1
ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Spire/${VERSION}/patch/spire.patch"
RUN apt-get update;apt-get install libssl-dev wget git make gcc curl vim -y \
# Build Spire
&& git clone -b v${VERSION} https://github.com/spiffe/spire.git \
&& cd spire \
&& curl -o spire.patch $PATCH_URL  \
&& git apply spire.patch \
&& make build-static
# For users that wish to run SPIRE containers as a non-root user,
# provide a default unprivileged user such that the default paths
# that SPIRE will try to read from, write to, and create at runtime
# can be given the correct file ownership/permissions at build time.
ARG spireuid=1000
ARG spiregid=1000
# Set up directories that SPIRE expects by default
# Set up base directories
RUN install -d -o root -g root -m 777 /spireroot
RUN install -d -o root -g root -m 755 /spireroot/etc/ssl/certs
RUN install -d -o root -g root -m 755 /spireroot/run
RUN install -d -o root -g root -m 755 /spireroot/var/lib
RUN install -d -o root -g root -m 1777 /spireroot/tmp
# Set up directories used by SPIRE
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireroot/etc/spire
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireroot/run/spire
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireroot/var/lib/spire
# Set up spire-server directories
RUN cp -r /spireroot /spireserverroot
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireserverroot/etc/spire/server
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireserverroot/run/spire/server/private
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireserverroot/var/lib/spire/server
# Set up spire-agent directories
RUN cp -r /spireroot /spireagentroot
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireagentroot/etc/spire/agent
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireagentroot/run/spire/agent/public
RUN install -d -o ${spireuid} -g ${spiregid} -m 755 /spireagentroot/var/lib/spire/agent

FROM ubuntu:22.04 AS spire-base
WORKDIR /opt/spire
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
CMD []
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# SPIRE Server
FROM spire-base AS spire-server
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/spire-server", "run"]
COPY --from=base /spireserverroot /
COPY --from=base /spire/spire/bin/static/spire-server bin/
# SPIRE Agent
FROM spire-base AS spire-agent
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/spire-agent", "run"]
COPY --from=base /spireagentroot /
COPY --from=base /spire/spire/bin/static/spire-agent bin/
# OIDC Discovery Provider
FROM spire-base AS oidc-discovery-provider
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
USER ${spireuid}:${spiregid}
ENTRYPOINT ["/opt/spire/bin/oidc-discovery-provider"]
COPY --from=base /spire/spire/bin/static/oidc-discovery-provider bin/
