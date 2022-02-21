# © Copyright IBM Corporation 2017, 2022.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Beats 7.16.3 #############################
# Beats is the platform for single-purpose data shippers
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create a container of Beats image run the below command:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# The following beats are present: heartbeat, filebeat, metricbeat, packetbeat, auditbeat, journalbeat
# To run:
# docker run --name <container_name> -e BEATNAME=<beat_name> -d <image_name> <flag/command>
#
# For example, run the following command for heartbeat:
# docker run --name <container_name> -e BEATNAME=heartbeat -d <image_name> help
#
# To configure beat, provide "<beat_name>.docker.yml" via a volume mount to /usr/share/beats, for example:
# docker run --name <container_name> --user=beats --volume="$(pwd)/heartbeat.docker.yml:/usr/share/beats/heartbeat.yml:ro" -e BEATNAME=heartbeat -d <image_name> <flag/command>
#
# Note : To run auditbeat use options : --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host to docker run
# docker run --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host --name <container_name> -e BEATNAME=auditbeat -d <image_name> <flag/command>
#
# For more information, see "Run <beat_name> on Docker" guide available at https://www.elastic.co/guide/index.html
###########################################################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG BEATS_VER=7.16.3

ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Beats/${BEATS_VER}/patch"

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:/usr/local/go/bin/:$GOPATH/bin:/usr/local/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    make \
    wget \
    tar \
    gcc \
    libcap-dev \
    libpcap0.8-dev \
    openssl \
    libssh-dev \
    acl \
    rsync \
    patch \
    fdclone \
    libffi-dev \
    libsystemd-dev \
    libjpeg-dev \
    libpython3-dev \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3-lib2to3 \
    python3.8-distutils \
# Install go and download beats source code
 && /usr/bin/update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10 \
 && /usr/bin/update-alternatives --set python3 /usr/bin/python3.8 \
 && /usr/bin/update-alternatives --display python3 \
 && python3 -V \
 && wget https://bootstrap.pypa.io/get-pip.py \
 && python3 get-pip.py \
 && rm get-pip.py \
 && cd $SOURCE_DIR \
 && wget -O rustup-init.sh https://sh.rustup.rs \
 && bash rustup-init.sh -y \
 && export PATH=$PATH:$HOME/.cargo/bin \
 && rustup toolchain install 1.49.0 \
 &&	rustup default 1.49.0 \
 && python3 -m pip install appdirs pyparsing packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv pillow \
 && wget https://go.dev/dl/go1.17.6.linux-s390x.tar.gz \
 && chmod ugo+r go1.17.6.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.17.6.linux-s390x.tar.gz \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v${BEATS_VER}  \
# Patching Beats dir
 && wget ${PATCH_URL}/beats.patch \
 && git apply --ignore-whitespace beats.patch \
# Building heartbeat
 && cd $GOPATH/src/github.com/elastic/beats/heartbeat  \
 && make heartbeat \
 && make update \
 && make fmt \
# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make filebeat \
 && make update \
 && make fmt \
# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make packetbeat \
 && make update \
 && make fmt \
# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && mage build \
 && mage update \
 && mage fmt \
# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make libbeat \
 && make update \
 && make fmt \
# Building auditbeat
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make auditbeat \
 && make update \
 && make fmt

# Setup directory layout
COPY directory-setup.sh $SOURCE_DIR
RUN chmod +x $SOURCE_DIR/directory-setup.sh \
 && $SOURCE_DIR/directory-setup.sh


FROM s390x/ubuntu:18.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV ELASTIC_CONTAINER "true"
ENV PATH=/usr/share/beats:$PATH

RUN apt-get update && apt-get install -y libpcap0.8 curl sudo \
 && curl --retry 8 -S -L -O "https://github.com/krallin/tini/releases/download/v0.19.0/tini-s390x" \
 && mv tini-s390x /usr/bin/tini \
 && chmod +x /usr/bin/tini

COPY docker-entrypoint /usr/local/bin/docker-entrypoint
RUN chmod 755 /usr/local/bin/docker-entrypoint

COPY --from=builder /usr/share/beats /usr/share/beats

RUN groupadd --gid 1000 beats \
 && useradd -M --uid 1000 --gid 1000 --groups sudo --home /usr/share/beats beats \
 && passwd -d beats

USER beats

ENV LIBBEAT_MONITORING_CGROUPS_HIERARCHY_OVERRIDE=/
ENV BEATNAME="filebeat"

WORKDIR /usr/share/beats
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint"]
CMD ["-environment", "container"]

#End of Dockerfile
