# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)


########## Dockerfile for Fluentd version 1.11.0 ###############################
#
# This Dockerfile builds a basic installation of Fluentd.
#
# Fluentd is an open source data collector for unified logging layer.
# Fluentd allows you to unify data collection and consumption for a better use and understanding of data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Fluentd process using below command :
# docker run --name <container_name> -d -p <host-port>:24224 <image-name>
# e.g. docker run --name fluentd_test -d -p 24224:24224 fluentd
# 
# To provide custom configuration for fluentd use below command:
# docker run --name <container_name> -d -p <host-port>:24224 -v /<host_path>/:/etc/fluent <image-name> fluentd <argument>
# e.g. docker run --name fluentd_test -d -p 24224:24224 -v /root/test/fluentd/:/etc/fluent/ fluentd fluentd -c /etc/fluent/fluent.conf
# 
# Official website: https://www.fluentd.org/
#
##############################################################################

# Base Image
FROM s390x/ubuntu:18.04

ARG FLUENTD_VER=1.11.0
ARG RUBY_VER=2.7.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR='/root'
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install  -y \
         gcc \
         make \
         wget \
         tar \
         bzip2 \
         subversion \
         bison \
         flex \
         openssl \
         libssl-dev \
         zlib1g-dev \
# Install Ruby
  && cd $SOURCE_DIR \
  && wget http://cache.ruby-lang.org/pub/ruby/2.7/ruby-${RUBY_VER}.tar.gz \
  && tar -xvf ruby-${RUBY_VER}.tar.gz \
  && cd ruby-${RUBY_VER} \
  && ./configure \
  && make \
  && make install \
# Install Fluentd
  && gem install fluentd -v ${FLUENTD_VER} \
  && gem list fluentd \
# Setup/Install a config directory
  && fluentd -s /etc/fluent \
  && mkdir -p /fluentd/log \
# Clean up the unwanted packages and clear the source directory 
  && rm -rf $SOURCE_DIR \
  && apt-get remove -y \
     gcc \
     make \
     bzip2 \
     bison \
     flex \
     openssl \
     subversion \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV PATH /usr/local/bin:$PATH
# Define port 
EXPOSE 24224 

# Start Fluentd process
CMD fluentd 

# End of Dockerfile
