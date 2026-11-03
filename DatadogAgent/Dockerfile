# © Copyright IBM Corporation 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
# this file has been modified with the assistance of AI Tool [claude 4.6]
#
# Datadog Agent 7.79.2 Dockerfile for s390x (IBM Z) -- no omnibus.
#
# Derived from Dockerfiles/agent/Dockerfile. The Agent arrives as a
# hand-assembled artifact tarball (see scripts/7.79.2/image/make-artifact.sh)
# instead of an omnibus package, so the whole embedded-Python /
# integration-wheel chain is skipped.
#
# Deltas from upstream, all marked DELTA below:
#   D1  s6-overlay v3.2.3.2 instead of v2.2.0.3 -- v2 publishes no s390x asset.
#   D2  the v2-only /etc/s6/init/init-stage3 --pid=host override is dropped;
#       v3 has no such path. See the caveat in scripts/7.79.2/image/README.md.
#   D3  JMX / BouncyCastle-FIPS stages removed (they need the omnibus JRE+jars).
#   D4  embedded/ssl is populated from the distro CA bundle; omnibus normally
#       ships its own, and upstream symlinks /etc/ssl at it.
#   D5  chown/chmod of secret-generic-connector and private-action-runner
#       removed -- those binaries are not in this artifact.
#   D6  s6 services for components this image does not ship are removed.
#
# Build (from an x86_64 or s390x host with qemu-s390x binfmt registered):
#   docker build --platform linux/s390x \
#     -f dockerfiles/DatadogAgent.dockerfile \
#     --build-context artifacts=./artifacts \
#     -t datadog-agent-s390x:7.79.2 \
#     ./src/Dockerfiles/agent

ARG BASE_IMAGE_UBUNTU_VERSION=24.04
ARG BASE_IMAGE_REGISTRY=mirror.gcr.io

FROM ${BASE_IMAGE_REGISTRY}/library/ubuntu:$BASE_IMAGE_UBUNTU_VERSION AS baseimage
ARG BASE_IMAGE_UBUNTU_VERSION
LABEL baseimage.name="ubuntu:${BASE_IMAGE_UBUNTU_VERSION}"
LABEL org.opencontainers.image.base.name="ubuntu:${BASE_IMAGE_UBUNTU_VERSION}"
LABEL org.opencontainers.image.title="Datadog Agent (s390x)"
ENV DEBIAN_FRONTEND=noninteractive

########################################################################
#  Ensure glibc doesn't call syscalls that may not be supported        #
########################################################################
FROM baseimage AS nosys-seccomp
RUN apt-get update && apt-get install --no-install-recommends -y gcc libc6-dev libseccomp-dev
COPY nosys-seccomp/nosys.c   /tmp/nosys.c
COPY nosys-seccomp/nosys.sym /tmp/nosys.sym
RUN gcc -pipe -Wall -Wextra -O2 -shared -fPIC \
    -Wl,--version-script=/tmp/nosys.sym -o /tmp/nosys.so /tmp/nosys.c -lseccomp

FROM baseimage AS extract-base
RUN apt-get update && apt-get install --no-install-recommends -y curl ca-certificates xz-utils

############################################################
#  Preparation stage: 3rd party dependencies               #
############################################################
FROM extract-base AS external-deps
# DELTA D1: upstream pins s6-overlay v2.2.0.3 and selects the asset with
#   S6ARCH=$([ "$TARGETARCH" = "amd64" ] && echo amd64 || echo aarch64)
# which has no s390x branch, and v2.2.0.3 ships no s390x tarball at all.
# v3.2.3.2 does: s6-overlay-s390x.tar.xz.
ENV S6_VERSION=v3.2.3.2
ENV S6_DOWNLOAD=https://github.com/just-containers/s6-overlay/releases/download
WORKDIR /output
RUN curl -fsSL -o /output/s6-noarch.tar.xz ${S6_DOWNLOAD}/${S6_VERSION}/s6-overlay-noarch.tar.xz \
 && curl -fsSL -o /output/s6-arch.tar.xz   ${S6_DOWNLOAD}/${S6_VERSION}/s6-overlay-s390x.tar.xz
COPY s6.s390x.sha256 /output/s6.s390x.sha256
RUN cd /output && sha256sum -c s6.s390x.sha256 && rm -f s6.s390x.sha256

########################################################################
#  Base image for the release: everything but the Agent                #
########################################################################
FROM baseimage AS release-base

ENV DOCKER_DD_AGENT=true \
    PATH=/opt/datadog-agent/bin/agent/:/opt/datadog-agent/embedded/bin/:$PATH \
    CURL_CA_BUNDLE=/opt/datadog-agent/embedded/ssl/certs/cacert.pem \
    S6_KEEP_ENV=1 \
    S6_LOGGING=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_READ_ONLY_ROOT=1

RUN apt-get update \
 && apt-get full-upgrade -y \
 && apt-get install --no-install-recommends -y iproute2 libseccomp2 tzdata adduser ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*

# Extract s6-overlay (v3 layout: noarch first, then the arch tarball)
COPY --from=external-deps /output/s6-noarch.tar.xz /output/s6-arch.tar.xz /tmp/
RUN tar -C / -Jxpf /tmp/s6-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-arch.tar.xz \
 && rm -f /tmp/s6-noarch.tar.xz /tmp/s6-arch.tar.xz
# DELTA D2: upstream overrides /etc/s6/init/init-stage3 here to fix --pid=host.
# That path does not exist in s6-overlay v3; see README.md.

# S6 entrypoint, service definitions, healthcheck probe
#
# DELTA D8: upstream ships cont-init.d/*.sh mode 0644 because s6-overlay v2's
# legacy cont-init stage ran them through a shell. v3's legacy runner execs
# them directly and fails with "Permission denied" / exit 126, so they have to
# carry the executable bit.
COPY s6-services /etc/services.d/
COPY --chmod=755 cont-init.d /etc/cont-init.d/
COPY probe.sh initlog.sh /

# DELTA D9: v2 installed its binaries into /usr/bin and /bin (the upstream
# Dockerfile even does `tar xzf s6.tgz -C /usr ./bin` for exactly that). v3
# installs them under /command, so the `#!/usr/bin/execlineb -P` shebangs in
# s6-services/*/run and the `/bin/s6-svc` calls in */finish fail with
# "unable to spawn ./run ... No such file or directory". Expose the v2 paths.
RUN for f in /command/*; do ln -sf "$f" "/usr/bin/$(basename "$f")"; done \
 && printf '#!/bin/sh\nexec /command/eltest "$@"\n' > /usr/bin/s6-test \
 && chmod 0755 /usr/bin/s6-test
# ^ The bulk symlinks are safe: execline and s6-portable-utils are multicall
#   binaries that dispatch on argv[0], and each symlink keeps the right name.
#   s6-test is the exception -- execline renamed it to eltest, so a renaming
#   symlink would hand the multicall argv[0]="s6-test", which it does not
#   recognise; it then falls back to treating argv[1] as the subcommand and
#   dies with `execline: fatal: unknown subcommand: 256` (256 being the exit
#   code s6 reports for a signal-killed service). The services/*/finish
#   scripts call `s6-test ${1} -eq 0`, so they would always mis-evaluate.
#   A wrapper keeps argv[0]=eltest and the dispatch correct.
# DELTA D10: v2's legacy scandir was /var/run/s6/services; v3 uses /run/service.
RUN sed -i 's#/var/run/s6/services#/run/service#g' /etc/services.d/*/finish

##########################################################
#  Extract the Agent artifact                            #
##########################################################
FROM extract-base AS extract
ARG DD_AGENT_ARTIFACT=datadog-agent*-s390x.tar.xz
# ARTIFACT_SHA256 pins the artifact and doubles as a cache key: `RUN --mount=from=`
# does not invalidate the layer when the mounted tarball's contents change, so
# without this a rebuilt artifact is silently ignored.
#
# No default: the integrity gate is mandatory. An empty value must fail the
# build rather than skip verification, otherwise a caller that simply forgets
# --build-arg gets an unverified artifact baked into the image.
ARG ARTIFACT_SHA256
WORKDIR /output

COPY datadog*.yaml etc/datadog-agent/
COPY install_info  etc/datadog-agent/

RUN --mount=from=artifacts,target=/artifacts \
    if [ -z "${ARTIFACT_SHA256}" ]; then \
      echo "FATAL: --build-arg ARTIFACT_SHA256=<sha256> is required" >&2; exit 1; \
    fi \
 && artifact="$(ls /artifacts/${DD_AGENT_ARTIFACT})" \
 && echo "artifact: ${artifact}" \
 && echo "${ARTIFACT_SHA256}  ${artifact}" | sha256sum -c - \
 && tar xf "${artifact}" -C . \
 && rm -rf usr etc/init lib go/ \
 && find opt/datadog-agent/ -iname "*.a" -delete \
 && mkdir -p conf.d checks.d \
 && test -x opt/datadog-agent/bin/agent/agent

###########################################################
#  Release image                                          #
###########################################################
FROM release-base AS release
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
LABEL org.opencontainers.image.version="7.79.2"
LABEL org.opencontainers.image.description="Datadog Agent 7.79.2 built from source for s390x (no omnibus; no embedded Python or integrations)"

ENV DD_SECRET_BACKEND_COMMAND_ALLOW_GROUP_EXEC_PERM="true"

COPY --from=extract /output/ /

# DELTA D4: omnibus ships embedded/ssl; reuse the distro CA bundle instead.
RUN mkdir -p /opt/datadog-agent/embedded/ssl/certs \
 && cp /etc/ssl/certs/ca-certificates.crt /opt/datadog-agent/embedded/ssl/certs/cacert.pem

# DELTA D6: drop s6 services for components this image does not ship.
RUN rm -rf /etc/services.d/otel /etc/services.d/security \
           /etc/services.d/sysprobe /etc/services.d/privateactionrunner

# DELTA D7: upstream replaces the /var/run -> /run symlink with a real
# directory ("as some docker versions re-create /run from zero at container
# start"). s6-overlay v3's preinit *requires* /var/run to be that symlink and
# aborts with "s6-rmrf: fatal: unable to remove /var/run: Resource busy" if it
# is not. Under v3 we leave the symlink alone and let s6 provision its own
# scratch space in the /run tmpfs at startup.
#
# Prepare for running without root (otherwise identical to upstream, minus D5)
RUN adduser --system --no-create-home --disabled-password --ingroup root dd-agent \
 && addgroup --system secret-manager \
 && usermod -a -G secret-manager dd-agent \
 && mkdir -p /opt/datadog-agent/run /var/log/datadog \
 && chown -R dd-agent:root /etc/datadog-agent/ /var/log/datadog/ /opt/datadog-agent/run \
 && chmod g+r,g+w,g+X -R /etc/datadog-agent/ /var/log/datadog/ /opt/datadog-agent/run \
 && chmod 755 /probe.sh /initlog.sh

# Keep the uid-100 guarantee that Kubernetes securityContext users rely on
RUN [ "$(getent passwd dd-agent | cut -d: -f 3)" -eq 100 ]

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN find /etc -type d,f -perm -o+w -print0 | xargs -r -0 chmod g-w,o-w

EXPOSE 8125/udp 8126/tcp

HEALTHCHECK --interval=30s --timeout=5s --retries=2 \
  CMD ["/probe.sh"]

# DELTA D7 (cont.): /var/run/s6 is a v2 path; under v3 s6 lives in the /run tmpfs.
VOLUME ["/var/log/datadog"]

COPY --from=nosys-seccomp /tmp/nosys.so /opt/lib/nosys.so
ENV LD_PRELOAD=/opt/lib/nosys.so

COPY --chmod=755 entrypoint.sh /bin/entrypoint.sh
COPY --chmod=755 entrypoint.d /opt/entrypoints

CMD ["/bin/entrypoint.sh"]
