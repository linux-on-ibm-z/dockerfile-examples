# © Copyright IBM Corporation 2017, 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
################# Dockerfile for Puppet-master version 7.0.1 ####################
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
FROM s390x/ubuntu:20.04 as base

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT="/root/"
WORKDIR ${SOURCE_ROOT}

ENV LANG=en_US.UTF-8 SERVER_VERSION="7.0.1" JFFI_VERSION="1.3.1" JRUBY_VERSION="9.2.14.0"

ENV JDK8_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u265-b01_openj9-0.21.0/OpenJDK8U-jdk_s390x_linux_openj9_8u265b01_openj9-0.21.0.tar.gz"
ENV JDK11_URL="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.8_10.tar.gz"

# Setting SERVER
ARG SERVER=puppet
ENV MASTERHOST="${SERVER}"

# Install dependencies
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y g++ tar make git wget libsqlite3-dev libc6-dev cron locales locales-all unzip libyaml-dev zlibc zlib1g-dev zlib1g libxml2-dev libgdbm-dev libffi7 ruby ruby-dev ant zip

FROM base as jffi

# Install JDK 8
ADD "$JDK8_URL" "${SOURCE_ROOT}/openjdk8.tar.gz"
RUN mkdir openjdk8 \
 && tar -zxvf openjdk8.tar.gz -C openjdk8/ --strip-components 1 \
 && wget https://github.com/jnr/jffi/archive/jffi-$JFFI_VERSION.tar.gz \
 && tar xzf jffi-$JFFI_VERSION.tar.gz \
 && cd jffi-jffi-$JFFI_VERSION \
 && JAVA_HOME="${SOURCE_ROOT}/openjdk8" PATH="${SOURCE_ROOT}/openjdk8/bin:${PATH}" ant jar

FROM base as final

ENV JAVA_HOME="${SOURCE_ROOT}/openjdk11"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

#COPY puppetserver.conf /etc/puppetserver.conf
COPY --from=jffi "${SOURCE_ROOT}/jffi-jffi-${JFFI_VERSION}/build/native.jar" "${SOURCE_ROOT}/native.jar"

# Install lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /usr/bin/lein
RUN chmod +x /usr/bin/lein \
    && gem install bundler rake-compiler \
# Install OpenJDK11
    && wget -O ${SOURCE_ROOT}/openjdk11.tar.gz "$JDK11_URL" \
    && mkdir openjdk11 \
    && tar -zxvf openjdk11.tar.gz -C openjdk11/ --strip-components 1 \
    && rm openjdk11.tar.gz \
# Get puppetserver code
    && git clone --recursive --branch $SERVER_VERSION git://github.com/puppetlabs/puppetserver \
    && cd puppetserver \
    && ./dev-setup \
# Overwrite JFFI jar file in cache.
    && cp "${SOURCE_ROOT}/native.jar" "/root/.m2/repository/com/github/jnr/jffi/${JFFI_VERSION}/jffi-${JFFI_VERSION}-native.jar" \
    && rm -f /root/.puppetlabs/opt/server/data/puppetserver/vendored-jruby-gems/cache/*.gem \
# Update puppet.conf to set autosign to true. Remove this line if you don't want autosign setting
    && sed  -i '47i autosign=true' dev-setup \
# Build
    && ./dev-setup \
# Patch JRuby
    && unzip -q "/root/.m2/repository/org/jruby/jruby-stdlib/${JRUBY_VERSION}/jruby-stdlib-${JRUBY_VERSION}.jar" \
    && cp META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/powerpc-aix/*.rb META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/s390x-linux/ \
    && cp META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/powerpc-aix/platform.conf META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/s390x-linux/ \
    && zip -qr jruby-stdlib.jar META-INF \
    && cp jruby-stdlib.jar "/root/.m2/repository/org/jruby/jruby-stdlib/${JRUBY_VERSION}/jruby-stdlib-${JRUBY_VERSION}.jar" \
    && rm -rf META-INF jruby-stdlib.jar \
# Use default config if not provided
    && cp "${SOURCE_ROOT}/puppetserver/dev/puppetserver.conf" "/etc/puppetserver.conf"
    
EXPOSE 8140

WORKDIR "${SOURCE_ROOT}/puppetserver"

CMD ["lein", "run", "-c", "/etc/puppetserver.conf"]
