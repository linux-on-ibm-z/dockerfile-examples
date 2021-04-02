# © Copyright IBM Corporation 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Falco 0.23.0 ####################
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
# docker run --interactive --privileged --tty --name <container_name> --volume /var/run/docker.sock:/host/var/run/docker.sock --volume /dev:/host/dev --volume /proc:/host/proc:ro --volume /boot:/host/boot:ro --volume /lib/modules:/host/lib/modules:ro --volume /usr:/host/usr:ro -e HOST_ROOT=/host <image_name>
#
# For example
# docker run --interactive --privileged --tty --name falco --volume /var/run/docker.sock:/host/var/run/docker.sock --volume /dev:/host/dev --volume /proc:/host/proc:ro --volume /boot:/host/boot:ro --volume /lib/modules:/host/lib/modules:ro --volume /usr:/host/usr:ro -e HOST_ROOT=/host <image_name>
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
###########################################################################

# Base image
FROM s390x/ubuntu:18.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
WORKDIR /home/root/
ARG VERSION=0.23.0

RUN apt-get update \
&& apt-get install -y sudo git curl

RUN curl  -SLO https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Falco/${VERSION}/build_falco.sh \
&& chmod +x build_falco.sh \
&& sed -i 's/sudo make install/exit 0;/g' build_falco.sh \
&& bash build_falco.sh -y


FROM s390x/ubuntu:18.04

LABEL RUN="docker run -i -t -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"

ENV FALCO_REPOSITORY stable
ENV SYSDIG_HOST_ROOT /host
ENV HOME /root
ARG VERSION=0.23.0

RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

ADD http://download.draios.com/apt-draios-priority /etc/apt/preferences.d/

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash-completion \
        bc  clang-7  ca-certificates  curl  dkms  gnupg2 gcc \
        jq libc6-dev  libelf-dev llvm-7  netcat  xz-utils  \
        libgrpc++  libssl-dev libyaml-dev libncurses-dev libc-ares-dev libprotobuf-dev   \
        protobuf-compiler libjq-dev libyaml-cpp-dev protobuf-compiler-grpc        \
        libcurl4-openssl-dev libelf-dev   \
 && rm -rf /var/lib/apt/lists/*

RUN rm -rf /usr/bin/clang \
 && rm -rf /usr/bin/llc \
 && ln -s /usr/bin/clang-7 /usr/bin/clang \
 && ln -s /usr/bin/llc-7 /usr/bin/llc

COPY --from=0 /home/root/falco/build/release/falco-${VERSION}-s390x.deb .

RUN apt-get update && apt-get install -y libyaml-0-2   \
 && dpkg -i falco-${VERSION}-s390x.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* falco-${VERSION}-s390x.deb
# Change the falco config within the container to enable ISO 8601
# output.
RUN sed -e 's/time_format_iso_8601: false/time_format_iso_8601: true/' < /usr/local/etc/falco/falco.yaml > /etc/falco/falco.yaml.new \
 && mv /etc/falco/falco.yaml.new /etc/falco/falco.yaml  \
 && cp -fv /usr/local/etc/falco/falco_rules.yaml /etc/falco/falco_rules.yaml

RUN rm -df /lib/modules \
        && ln -s $HOST_ROOT/lib/modules /lib/modules

# binutils 2.31 generates
# binaries that are incompatible with kernels < 4.16. So manually
# forcibly install binutils 2.30-22 instead.
RUN curl -SLO http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils_2.30-22_s390x.deb \
 && curl -SLO http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/libbinutils_2.30-22_s390x.deb \
 && curl -SLO http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils-s390x-linux-gnu_2.30-22_s390x.deb \
 && curl -SLO http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils-common_2.30-22_s390x.deb \
 && dpkg -i *binutils*.deb \
 && rm -f *binutils*.deb

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/falco"]
