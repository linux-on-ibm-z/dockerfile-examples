# © Copyright IBM Corporation 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
################# Dockerfile for Puppet server version 7.4.1 ####################
#
# This Dockerfile builds a basic installation of Puppet server.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> --build-arg SERVER=<server_hostname> .
#
# To Start Puppet master run the below command:
# docker run --name <container_name> --hostname <server_hostname> -v /<path-to-puppet.config-file>:/etc/puppetserver.config -p <port>:8140 -d <image_name>
#
##################################################################################

# Base image
FROM s390x/ubuntu:18.04 as base

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT="/root/"
WORKDIR ${SOURCE_ROOT}

ENV LANG=en_US.UTF-8 SERVER_VERSION="7.4.1" JRUBY_VERSION="9.2.17.0"

ENV JDK11_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.13_8.tar.gz"

# Setting SERVER
ARG SERVER=puppet
ENV MASTERHOST="${SERVER}"

# Setting Java environment
ENV JAVA_HOME="${SOURCE_ROOT}/adoptium11"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/s390x-linux-gnu/jni/${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

# Install dependencies
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
 g++ \
 tar \
 git \
 make \
 wget \
 locales \
 locales-all \
 unzip \
 ruby-dev \
 ant \
 zip \
 libjffi-jni \
# Install Eclipse Adoptium Temurin Runtime (Java 11)
 && wget -O ${SOURCE_ROOT}/adoptium11.tar.gz "$JDK11_URL" \
 && mkdir adoptium11 \
 && tar -zxvf adoptium11.tar.gz -C adoptium11/ --strip-components 1 \
 && rm adoptium11.tar.gz

# Install lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /usr/bin/lein
RUN chmod +x /usr/bin/lein \
    && gem install bundler rake-compiler \
# Get puppetserver code
    && git clone --recursive --branch $SERVER_VERSION git://github.com/puppetlabs/puppetserver \
    && cd puppetserver \
# Update puppet.conf to set autosign to true. Remove this line if you don't want autosign setting
    && sed  -i '47i autosign=true' dev-setup \
# Build
    && ./dev-setup \
# Patch JRuby
    && unzip -q "/root/.m2/repository/org/jruby/jruby-stdlib/${JRUBY_VERSION}/jruby-stdlib-${JRUBY_VERSION}.jar" \
    && cp META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/powerpc-aix/syslog.rb META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/s390x-linux/ \
    && zip -qr jruby-stdlib.jar META-INF \
    && cp jruby-stdlib.jar "/root/.m2/repository/org/jruby/jruby-stdlib/${JRUBY_VERSION}/jruby-stdlib-${JRUBY_VERSION}.jar" \
    && rm -rf META-INF jruby-stdlib.jar \
# Use default config if not provided
    && cp "${SOURCE_ROOT}/puppetserver/dev/puppetserver.conf" "/etc/puppetserver.conf" \
# Cleanup
    && apt-get -y remove \
    git \
    unzip \
    wget \
    zip \
    && apt-get autoremove -y \
    && apt autoremove -y \
    && rm -rf /root/.cache/ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8140

WORKDIR "${SOURCE_ROOT}/puppetserver"

CMD ["lein", "run", "-c", "/etc/puppetserver.conf"]
