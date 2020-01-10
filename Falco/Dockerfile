# © Copyright IBM Corporation 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################## Dockerfile for Falco 0.18.0 ####################
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
# docker run --interactive --privileged --tty --name <container_name> --volume /var/run/docker.sock:/host/var/run/docker.sock --volume /dev:/host/dev --volume /proc:/host/proc:ro --volume /boot:/host/boot:ro --volume /lib/modules:/host/lib/modules:ro --volume /usr:/host/usr:ro <image_name>
#
# For example
# docker run --interactive --privileged --tty --name falco --volume /var/run/docker.sock:/host/var/run/docker.sock --volume /dev:/host/dev --volume /proc:/host/proc:ro --volume /boot:/host/boot:ro --volume /lib/modules:/host/lib/modules:ro --volume /usr:/host/usr:ro <image_name>
#
#
###########################################################################

# Base image
FROM s390x/ubuntu:18.04
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
WORKDIR /home/root/
RUN apt-get update \
&& apt-get install -y wget sudo git curl
RUN wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Falco/0.18.0/build_falco.sh && chmod +x build_falco.sh \
&& sed -i 's/sudo make install/exit 0;/g' build_falco.sh \
&& bash build_falco.sh -b -y


FROM s390x/debian:unstable
ENV FALCO_REPOSITORY stable
LABEL RUN="docker run -i -t -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"
ENV SYSDIG_HOST_ROOT /host
ENV HOME /root
RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root
ADD http://download.draios.com/apt-draios-priority /etc/apt/preferences.d/
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        bash-completion \
        bc \
        clang-7 \
        ca-certificates \
        curl \
        dkms \
        gnupg2 \
        gcc \
        jq \
        lua5.1 \
        lua5.1-dev \
        libc6-dev \
        libelf-dev \
        llvm-7 \
        netcat \
        xz-utils \
 && rm -rf /var/lib/apt/lists/*

# Since our base Debian image ships with GCC 7 which breaks older kernels, revert the
# default to gcc-5.
#RUN rm -rf /usr/bin/gcc && ln -s /usr/bin/gcc-5 /usr/bin/gcc
RUN rm -rf /usr/bin/clang \
 && rm -rf /usr/bin/llc \
 && ln -s /usr/bin/clang-7 /usr/bin/clang \
 && ln -s /usr/bin/llc-7 /usr/bin/llc
#Copy .deb from builder image
COPY --from=0 /home/root/falco/build/release/falco-0.18.0-s390x.deb .
RUN curl -s https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add - \
 && curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/$FALCO_REPOSITORY/deb/draios.list \
 && apt-get update \
 && dpkg -i falco-0.18.0-s390x.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
# Change the falco config within the container to enable ISO 8601
# output.
RUN sed -e 's/time_format_iso_8601: false/time_format_iso_8601: true/' < /etc/falco/falco.yaml > /etc/falco/falco.yaml.new \
 && mv /etc/falco/falco.yaml.new /etc/falco/fllco.yaml
# Some base images have an empty /lib/modules by default
# If it's not empty, docker build will fail instead of
# silently overwriting the existing directory
RUN rm -df /lib/modules \
 && ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules
# debian:unstable head contains binutils 2.31, which generates
# binaries that are incompatible with kernels < 4.16. So manually
# forcibly install binutils 2.30-22 instead.
RUN curl -s -o binutils_2.30-22_s390x.deb http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils_2.30-22_s390x.deb \
 && curl -s -o libbinutils_2.30-22_s390x.deb http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/libbinutils_2.30-22_s390x.deb \
 && curl -s -o binutils-x86-64-linux-gnu_2.30-22_s390x.deb http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils-s390x-linux-gnu_2.30-22_s390x.deb \
 && curl -s -o binutils-common_2.30-22_s390x.deb http://snapshot.debian.org/archive/debian/20180622T211149Z/pool/main/b/binutils/binutils-common_2.30-22_s390x.deb \
 && dpkg -i *binutils*.deb \
 && rm -f *binutils*.deb
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/falco"]
