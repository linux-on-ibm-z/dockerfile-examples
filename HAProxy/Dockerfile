######################### Dockerfile for HAProxy version 1.6.3 ####################################################
#
# This Dockerfile builds a basic installation of HAProxy.
#
# HAProxy is free, open source software that provides a high availability load balancer
# and proxy server for TCP and HTTP-based applications that spreads requests across multiple servers.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start HAProxy use following command:
# docker run --name <container_name> -v /<path-to-haproxy.config-file>:/etc/haproxy.config -p <port>:80 -d <image_name>
#
# For ex. docker run --name <container_name> -v /haproxy.config:/etc/haproxy.config -p <port>:80 -d <image_name>
#
# Please note that you will need to expose ports based on your haproxy configuration file.
# Sample configure file is available in https://github.com/linux-on-ibm-z/docs/wiki/Building-HAProxy
#
#########################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Install dependencies and  HAProxy
RUN apt-get update && apt-get install -y \
    gcc \
    make \
	tar \
	wget \		
 && wget http://www.haproxy.org/download/1.7/src/haproxy-1.7.5.tar.gz \
 && tar xzvf haproxy-1.7.5.tar.gz \
 && cd haproxy-1.7.5 \
 && make TARGET=linux26  \
 && make install \
 
# Remove cache data and unused packages
 && apt-get remove -y wget && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/haproxy-1.7.5.tar.gz /root/haproxy-1.7.5 \
 && rm -rf /var/lib/apt/lists/*

# Start HAProxy server
CMD  ["/usr/local/sbin/haproxy" ,"-db", "-f", "/etc/haproxy.config"]

# End of Dockerfile
