# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Zabbix-Agent version 5.0.17 ####################
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
# docker run --name <container_name> -e ZBX_SERVER_HOST="server_ip" -d <image>
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
#               1. Enter the Zabbix Server container IP as value of ZBX_SERVER_HOST while starting agent container.
#
####################################################################################

# Base Image
FROM s390x/ubuntu:18.04

ARG ZBX_AGENT_VER=5.0.17

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH=$PATH:/usr/local/sbin/
ENV TINI_VERSION="v0.19.0"

WORKDIR $SOURCE_DIR

COPY ["docker-entrypoint.sh", "/docker-entrypoint.sh"]

# Install dependencies
RUN apt-get update && apt-get -y install \
                vim\
                curl \
                gosu \
                jq \
                sudo \
                gcc \
                make \
                tar \
                wget \
                libpcre3-dev \
# Download tini
        && curl -L --fail --silent --show-error "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-s390x" > /sbin/tini \
        && chmod +x /sbin/tini \
# Download Zabbix agent
        && wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-${ZBX_AGENT_VER}.tar.gz  \
        && tar -xf zabbix-${ZBX_AGENT_VER}.tar.gz \
# Install Zabbix agent
        && cd $SOURCE_DIR/zabbix-${ZBX_AGENT_VER}\
        && mkdir -p /etc/zabbix/zabbix_agentd.d \
        && mkdir -p /var/lib/zabbix \
        && mkdir -p /var/lib/zabbix/enc \
        && mkdir -p /var/lib/zabbix/modules \
        && ./configure --enable-agent \
        && make \
        && make install \
# Create a 'zabbix' user required to start Zabbix agent daemon
        && /usr/sbin/groupadd zabbix \
        && /usr/sbin/useradd -g zabbix zabbix \
        && chown -R zabbix:zabbix /usr/local/etc /var/lib/zabbix \
        && chmod +x /docker-entrypoint.sh \
# Clean up cache data and remove dependencies which are not required
        &&      apt-get -y remove \
                gcc \
                make \
                wget \
        &&      apt-get autoremove -y \
        &&      apt autoremove -y \
        &&      apt-get clean \
        &&      rm -rf $SOURCE_DIR /var/lib/apt/lists/*

EXPOSE 10050/TCP

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]

# change user to zabbix
USER zabbix

# Start Zabbix agent
CMD ["/usr/local/sbin/zabbix_agentd", "--foreground", "-c", "/usr/local/etc/zabbix_agentd.conf"]

# End of Dockerfile
