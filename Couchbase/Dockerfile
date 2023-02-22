# © Copyright IBM Corporation  2017, 2023
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Couchbase version 7.1.1 ###################################
#
# Couchbase is open source database software.
#
# To build Couchbase image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start Couchbase server run the below command
# docker run --name <container_name> -p <port_numbers>:8091-8094 -p <port_number>:9123 -p <port_number>:11210 -d <image_name>
#
# View Couchbase UI at http://localhost:8091 on host machine to start Couchbase Server setup
#
##########################################################################################

FROM s390x/ubuntu:20.04 as builder

ENV SOURCE_ROOT=/tmp/source
WORKDIR $SOURCE_ROOT
ARG PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Couchbase/7.1.1

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y sudo wget locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN cd $SOURCE_ROOT \
&& wget $PATCH_URL/build_couchbase.sh \
&& bash build_couchbase.sh -p /opt/couchbase 

FROM s390x/ubuntu:20.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
WORKDIR /opt

COPY --from=builder /opt/couchbase ./couchbase

SHELL ["/bin/bash", "-c"]
# Install dependencies:
#  runit: for container process management
#  wget: for downloading .deb
#  chrpath: for fixing curl, below
#  tzdata: timezone info used by some N1QL functions
# Additional dependencies for system commands used by cbcollect_info:
#  lsof: lsof
#  lshw: lshw
#  sysstat: iostat, sar, mpstat
#  net-tools: ifconfig, arp, netstat
RUN set -x && \
    apt-get update && \
    apt-get install -yq runit wget chrpath patchelf tzdata libgflags2.2 \
    lsof lshw sysstat net-tools bzip2 && \
    apt-get autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# http://smarden.org/runit/useinit.html#sysv - at some point the script
# runsvdir-start was moved/renamed to this odd name, so we put it back
# somewhere sensible. This appears to be necessary for Ubuntu 20 but
# not Ubuntu 16.
RUN if [ ! -x /usr/sbin/runsvdir-start ]; then \
        cp -a /etc/runit/2 /usr/sbin/runsvdir-start; \
    fi

ENV PATH=$PATH:/opt/couchbase/bin:/opt/couchbase/bin/tools:/opt/couchbase/bin/install
ENV LD_LIBRARY_PATH=/opt/couchbase/lib

# Create Couchbase user with UID 1000 (necessary to match default
# boot2docker UID)
RUN groupadd -g 1000 couchbase && useradd couchbase -u 1000 -g couchbase -M

# Add runit script for couchbase-server
COPY scripts/run /etc/service/couchbase-server/run
RUN chmod a+x /etc/service/couchbase-server/run \
    && mkdir -p /etc/runit/runsvdir/default/couchbase-server/supervise \
    && chown -R couchbase:couchbase \
                /etc/service \
                /etc/runit/runsvdir/default/couchbase-server/supervise

# Add dummy script for commands invoked by cbcollect_info that
# make no sense in a Docker container
COPY scripts/dummy.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/dummy.sh && \
    ln -s dummy.sh /usr/local/bin/iptables-save && \
    ln -s dummy.sh /usr/local/bin/lvdisplay && \
    ln -s dummy.sh /usr/local/bin/vgdisplay && \
    ln -s dummy.sh /usr/local/bin/pvdisplay

# Fix curl RPATH
RUN patchelf --set-rpath '$ORIGIN/../lib' /opt/couchbase/bin/curl

# Add bootstrap script
COPY scripts/entrypoint.sh /
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchbase-server"]

# 8091: Couchbase Web console, REST/HTTP interface
# 8092: Views, queries, XDCR
# 8093: Query services (4.0+)
# 8094: Full-text Search (4.5+)
# 8095: Analytics (5.5+)
# 8096: Eventing (5.5+)
# 9123: Prometheus
# 11207: Smart client library data node access (SSL)
# 11210: Smart client library/moxi data node access
# 11211: Legacy non-smart client library data node access
# 18091: Couchbase Web console, REST/HTTP interface (SSL)
# 18092: Views, query, XDCR (SSL)
# 18093: Query services (SSL) (4.0+)
# 18094: Full-text Search (SSL) (4.5+)
# 18095: Analytics (SSL) (5.5+)
# 18096: Eventing (SSL) (5.5+)
EXPOSE 8091 8092 8093 8094 8095 8096 9123 11207 11210 11211 18091 18092 18093 18094 18095 18096
VOLUME /opt/couchbase/var
