# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Logstash version 7.6.2 #####################################################
#
# This Dockerfile builds a basic installation of Logstash
#
# Logstash is a tool for managing events and logs. When used generically the term
# encompasses a larger system of log collection, processing, storage and searching activities.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Logstash using the below command
# docker run --name <container name> -v <path_on_host>/logstash.conf:/etc/logstash/logstash.conf -d <logstash_image>
###############################################################################################################

# Base image
FROM s390x/ubuntu:18.04

ARG LOGSTASH_VER=7.6.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

WORKDIR "/opt"
ENV JAVA_HOME=/opt/jdk8u222-b10/
ENV PATH=$JAVA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/lib/s390x-linux-gnu/jni/:$LD_LIBRARY_PATH
# Install dependencies
RUN apt-get update && apt-get install -y \
    ant \
    gcc \
    gzip \
    libjffi-jni \
    make \
    tar \
    unzip \
    wget \
    zip \
# Download OpenJDK 8 with HotSpot
 && wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u222-b10/OpenJDK8U-jdk_s390x_linux_hotspot_8u222b10.tar.gz \
 && tar -xvf OpenJDK8U-jdk_s390x_linux_hotspot_8u222b10.tar.gz \
# Download and Install Logstash
 && cd /opt \
 && wget https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VER}.tar.gz \
 && mkdir /usr/share/logstash \
 && tar -xzf logstash-${LOGSTASH_VER}.tar.gz  -C /usr/share/logstash --strip-components 1 \
# Copy types.conf to platform.conf, re-create and copy the jar
 && cd /usr/share/logstash/logstash-core/lib/jars \
 && unzip jruby-complete-9.2.9.0.jar -d jruby-complete-9.2.9.0 \
 && cd jruby-complete-9.2.9.0/META-INF/jruby.home/lib/ruby/stdlib/ffi/platform/s390x-linux \
 && cp -n types.conf platform.conf \
 && cd /usr/share/logstash/logstash-core/lib/jars/jruby-complete-9.2.9.0 \
 && zip -r ../jruby-complete-9.2.9.0.jar * \
 && cd  /usr/share/logstash/ \
 && rm -rf /usr/share/logstash/logstash-core/lib/jars/jruby-complete-9.2.9.0 \
# Cleanup Cache data , unused packages and source files
 && apt-get remove -y \
    ant \
    gcc \
    make \
    unzip \
    wget \
    zip \
 && apt-get autoremove -y && apt-get clean \
 && rm /opt/OpenJDK8U-jdk_s390x_linux_hotspot_8u222b10.tar.gz \
 && rm -rf /opt/logstash-${LOGSTASH_VER} \
 && rm /opt/logstash-${LOGSTASH_VER}.tar.gz \
 && rm -rf /var/lib/apt/lists/* \
# Create elasticsearch user
 && /usr/sbin/groupadd logstash \
 && /usr/sbin/useradd -g logstash logstash \
 && usermod -aG sudo logstash \
 && chown logstash:logstash -R /usr/share/logstash

# Expose the default port
USER logstash

# Expose ports
EXPOSE 514 5043 5000 9292

ENV PATH=/usr/share/logstash/bin:$PATH

CMD ["logstash"]
# End of Dockerfile
