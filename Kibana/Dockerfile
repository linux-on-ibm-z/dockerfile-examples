# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 7.11.2 ############################################
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
# Base Image
FROM s390x/ubuntu:18.04 AS builder

ARG KIBANA_VER=7.11.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set Environment Variable
ENV PATH=/home/kibana/.yarn/bin:/home/kibana/.config/yarn/global/node_modules/.bin:/usr/share/kibana/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/${KIBANA_VER}/patch"
ENV NODE_OPTIONS="--max_old_space_size=4096"

# Set up Kibana user
RUN apt-get update && apt-get install sudo && groupadd -r kibana \
 && useradd -g kibana -m kibana \
 && echo "kibana ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER kibana
ENV WORKDIR=/home/kibana
# Install the dependencies
RUN sudo apt-get update && sudo apt-get install -y \
    curl \
    git \
    g++ \
    gzip \
    libssl-dev \
    make \
    python \
    sudo \
    tar \
    wget \
    patch \
    pkg-config \
    libpixman-1-dev \
    libcairo2-dev \
    libpangocairo-1.0-0 \
    libpango1.0-dev libjpeg-dev \
    libre2-dev xz-utils \
# Installing Node.js v14.16.0
 && sudo mkdir -p /usr/local/lib/nodejs \
 && cd $WORKDIR && sudo wget https://nodejs.org/dist/v14.16.0/node-v14.16.0-linux-s390x.tar.gz \
 && sudo tar xzf node-v14.16.0-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
 && sudo ln -s /usr/local/lib/nodejs/node-v14.16.0-linux-s390x/bin/* /usr/bin/ \
# Install Yarn
 && curl -o- -L https://yarnpkg.com/install.sh | bash \
# Download and Install Kibana
 && cd $WORKDIR && git clone -b v${KIBANA_VER} https://github.com/elastic/kibana.git \
 && cd $WORKDIR/kibana \
# Apply Kibana patch
 && curl -o kibana_patch.diff $PATCH_URL/kibana_patch.diff \
 && git apply kibana_patch.diff \
# Build re2
 && cd $WORKDIR && git clone https://github.com/uhop/node-re2.git \
 && cd node-re2 && git checkout 1.15.4 \
 && git submodule update --init --recursive \
 && npm install \
 && gzip -c build/Release/re2.node > $WORKDIR/linux-s390x-83.gz \
 && mkdir -p $WORKDIR/kibana/.native_modules/re2/ \
 && cp $WORKDIR/linux-s390x-83.gz $WORKDIR/kibana/.native_modules/re2/ \
# Bootstrap Kibana
 && cd $WORKDIR/kibana \
 && yarn kbn bootstrap --oss \
 && yarn build --skip-os-packages --oss \
 && sudo mkdir /usr/share/kibana/ \
 && sudo tar xzf target/kibana-oss-${KIBANA_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/kibana --strip-components 1 \
 && sudo chown kibana:kibana -R /usr/share/kibana/ \
# Cleanup Cache data, unused packages and source files
&& sudo apt-get remove -y \
    curl \
    git \
    g++ \
    wget \
 && sudo apt-get autoremove -y && sudo apt-get clean \
 && sudo rm -rf $WORKDIR/kibana* $WORKDIR/node-v14.16.0-linux-s390x.tar.gz \
 && sudo rm -rf /var/lib/apt/lists/* $HOME/.cache

FROM s390x/ubuntu:18.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
# Expose 5601 port used by Kibana
EXPOSE 5601

RUN apt-get update && apt-get install -y sudo wget tar curl \
&& sudo mkdir -p /usr/local/lib/nodejs \
&& wget https://nodejs.org/dist/v14.16.0/node-v14.16.0-linux-s390x.tar.gz \
&& sudo tar xzf node-v14.16.0-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
&& rm node-v14.16.0-linux-s390x.tar.gz \
&& sudo ln -s /usr/local/lib/nodejs/node-v14.16.0-linux-s390x/bin/* /usr/bin/

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

# Bring in Kibana from the initial stage.
COPY --from=builder --chown=1000:0 /usr/share/kibana /usr/share/kibana
WORKDIR /usr/share/kibana
RUN ln -s /usr/share/kibana /opt/kibana

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/kibana/bin:$PATH

# Set some Kibana configuration defaults.
COPY --chown=1000:0 config/kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY --chown=1000:0 bin/kibana-docker /usr/local/bin/
RUN chmod +x /usr/local/bin/kibana-docker

# Ensure gid 0 write permissions for OpenShift.
RUN chmod g+ws /usr/share/kibana && \
    find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

# Remove the suid bit everywhere to mitigate "Stack Clash"
RUN find / -xdev -perm -4000 -exec chmod u-s {} +

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 kibana \
&& useradd --uid 1000 --gid 1000 -G 0 \
      --home-dir /usr/share/kibana --no-create-home \
      kibana \
&& echo "kibana ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
&& sudo apt-get autoremove -y && sudo apt-get clean \
&& sudo rm -rf /var/lib/apt/lists/* $HOME/.cache

USER kibana

ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/kibana-docker"]
