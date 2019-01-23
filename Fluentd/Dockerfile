# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Fluentd version 1.3.3 ###############################
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
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install  -y \
         gcc \
         make \
         ruby \
         ruby-dev \
# Install Fluentd
  && gem install fluentd -v 1.3.3 \
  && gem list fluentd \
# Setup/Install a config directory
  && fluentd -s /etc/fluent \
  && mkdir -p /fluentd/log \
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
         gcc \
         make \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*  

# Define port 
EXPOSE 24224 

# Start Fluentd process
CMD fluentd 

# End of Dockerfile
