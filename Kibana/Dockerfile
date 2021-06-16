# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 7.12.1 ############################################
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
FROM s390x/ubuntu:20.04 AS builder

ARG KIBANA_VER=7.12.1
ARG NODE_JS_VERSION=14.16.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Set Environment Variable
ENV WORKDIR=/home/kibana
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV PATH=/usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x/bin:/usr/share/kibana/bin:$JAVA_HOME/bin:$WORKDIR/bazel/output/:$PATH
ENV USE_BAZEL_VERSION=$WORKDIR/bazel/output/bazel
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/${KIBANA_VER}/patch"
ENV NODE_OPTIONS="--max_old_space_size=4096"

# Set up Kibana user
RUN apt-get update && apt-get install sudo && groupadd -r kibana \
 && useradd -g kibana -m kibana \
 && echo "kibana ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER kibana
# Install the dependencies
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    curl \
    git \
    g++ \
    gzip \
    make \
    python \
    python3 \
    openjdk-11-jdk \
    unzip \
    zip \
    tar \
    wget \
    patch \
    xz-utils \
# Installing Bazel \
 && cd $WORKDIR && mkdir bazel && cd bazel \
 && wget https://github.com/bazelbuild/bazel/releases/download/4.0.0/bazel-4.0.0-dist.zip \
 && unzip bazel-4.0.0-dist.zip \
 && chmod -R +w . \
 && curl -sSL https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/4.0.0/patch/bazel.patch | patch -p1 \
 && bash ./compile.sh \
# Installing Go \
 && cd $WORKDIR && wget -q https://storage.googleapis.com/golang/go1.16.3.linux-s390x.tar.gz \
 && sudo tar -C /usr/local -xzf go1.16.3.linux-s390x.tar.gz \
 && sudo ln -sf /usr/local/go/bin/go /usr/bin/ \
# Building Bazelisk binary \
 && cd $WORKDIR && git clone https://github.com/bazelbuild/bazelisk.git \
 && cd bazelisk && git checkout v1.7.5 \
 && curl -sSL $PATCH_URL/bazelisk_patch.diff | git apply --ignore-whitespace \
 && go build && ./bazelisk build --config=release //:bazelisk-linux-s390x \
# Installing Node.js
 && sudo mkdir -p /usr/local/lib/nodejs \
 && cd $WORKDIR && wget https://nodejs.org/dist/v${NODE_JS_VERSION}/node-v${NODE_JS_VERSION}-linux-s390x.tar.gz \
 && sudo tar xzf node-v${NODE_JS_VERSION}-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
# Install Yarn and patch Bazelisk
 && sudo chmod ugo+w -R /usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x \
 && npm install -g yarn @bazel/bazelisk@1.7.5 \
 && BAZELISK_DIR=/usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x/lib/node_modules/@bazel/bazelisk \
 && curl -sSL $PATCH_URL/bazelisk.js.diff | patch $BAZELISK_DIR/bazelisk.js \
 && cp $WORKDIR/bazelisk/bazel-out/s390x-opt-*/bin/bazelisk-linux_s390x $BAZELISK_DIR \
# Download and Install Kibana
 && cd $WORKDIR && git clone -b v${KIBANA_VER} https://github.com/elastic/kibana.git \
 && cd $WORKDIR/kibana \
# Apply Kibana patch
 && curl -sSL $PATCH_URL/kibana_patch.diff | git apply \
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
 && sudo rm -rf $WORKDIR/kibana* $WORKDIR/node-v${NODE_JS_VERSION}-linux-s390x.tar.gz \
 && sudo rm -rf $WORKDIR/Bazel $WORKDIR/Bazelisk $WORKDIR/go1.16.3.linux-s390x.tar.gz \
 && sudo rm -rf /var/lib/apt/lists/* $HOME/.cache

FROM s390x/ubuntu:20.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
# Expose 5601 port used by Kibana
EXPOSE 5601

ARG NODE_JS_VERSION=14.16.1

RUN apt-get update && apt-get install -yq sudo wget tar curl \
&& mkdir -p /usr/local/lib/nodejs \
&& wget https://nodejs.org/dist/v${NODE_JS_VERSION}/node-v${NODE_JS_VERSION}-linux-s390x.tar.gz \
&& tar xzf node-v${NODE_JS_VERSION}-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
&& rm node-v${NODE_JS_VERSION}-linux-s390x.tar.gz \
&& ln -s /usr/local/lib/nodejs/node-v${NODE_JS_VERSION}-linux-s390x/bin/* /usr/bin/


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

# Ensure gid 0 write permissions for OpenShift.
RUN chmod g+ws /usr/share/kibana && \
    chmod +x /usr/local/bin/kibana-docker && \
    find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

# Remove the suid bit everywhere to mitigate "Stack Clash"
RUN find / -xdev -perm -4000 -exec chmod u-s {} +

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 kibana && \
    useradd --uid 1000 --gid 1000 -G 0 \
      --home-dir /usr/share/kibana --no-create-home \
      kibana \
&& echo "kibana ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
&& sudo apt-get autoremove -y && sudo apt-get clean \
&& sudo rm -rf /var/lib/apt/lists/* $HOME/.cache

USER kibana

ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/kibana-docker"]
