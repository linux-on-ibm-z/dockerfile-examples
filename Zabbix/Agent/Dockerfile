# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Zabbix-Agent version 5.0.4 ####################
#
# This Dockerfile builds a basic installation of Zabbix-Agent.
#
# Zabbix is an enterprise-class open source distributed monitoring solution.
# Zabbix is software that monitors numerous parameters of a network and the health and integrity of servers.
# Zabbix uses a flexible notification mechanism that allows users to configure e-mail based alerts for virtually any event.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Zabbix agent run the below command:
# docker run --name <container_name> -d <image>
#
# Test by using the following url:
# docker exec <container_ID> zabbix_get -s <host_ip> -k "agent.version"
#
# Reference:
# https://www.zabbix.com/documentation/5.0/manual/installation
#
##################################################################################
#
#       NOTE:-
#               ** To configure zabbix agent with zabbix server please follow instructions below:
#               1. Edit Zabbix agent configuration file /usr/local/etc/zabbix_agentd.conf
#               2. Enter Zabbix server IP address and Hostname in configuration file
#
####################################################################################

# Base Image
FROM s390x/ubuntu:18.04

ARG ZBX_AGENT_VER=5.0.4

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH=$PATH:/usr/local/sbin/

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get -y install \
                gcc \
                make \
                tar \
                wget \
                libpcre3-dev \
# Download Zabbix agent
        && wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-${ZBX_AGENT_VER}.tar.gz  \
        && tar -xf zabbix-${ZBX_AGENT_VER}.tar.gz \
# Install Zabbix agent
        && cd $SOURCE_DIR/zabbix-${ZBX_AGENT_VER}\
        && ./configure --enable-agent \
        && make \
        && make install \
# Create a 'zabbix' user required to start Zabbix agent daemon
        && /usr/sbin/groupadd zabbix \
        && /usr/sbin/useradd -g zabbix zabbix \
# Clean up cache data and remove dependencies which are not required
        &&      apt-get -y remove \
                gcc \
                make \
                wget \
        &&      apt-get autoremove -y \
        &&      apt autoremove -y \
        &&      rm -rf $SOURCE_DIR \
        &&      apt-get clean \
        &&      rm -rf /var/lib/apt/lists/*

# change user to zabbix
USER zabbix

# Start Zabbix agent
CMD zabbix_agentd -f

# End of Dockerfile
