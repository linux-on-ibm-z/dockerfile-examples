# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)


########## Dockerfile for Fluentd version 1.12.3 ###############################
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
FROM s390x/ubuntu:20.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG RUBY_VER=3.0.1

RUN apt-get update \
 && apt-get install -y \
         ca-certificates \
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
 && wget http://cache.ruby-lang.org/pub/ruby/3.0/ruby-${RUBY_VER}.tar.gz \
 && tar -xvf ruby-${RUBY_VER}.tar.gz \
 && cd ruby-${RUBY_VER} \
 && ./configure \
 && make \
 && make install \
 && cd ../ && apt-get install -y gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.10.18 \
 && gem install json -v 2.4.1 \
 && gem install async-http -v 0.54.0 \
 && gem install ext_monitor -v 0.1.2 \
 && gem install fluentd -v 1.12.3 \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /bin/tini "https://github.com/krallin/tini/releases/download/v0.18.0/tini-$dpkgArch" \
 && wget -O /bin/tini.asc "https://github.com/krallin/tini/releases/download/v0.18.0/tini-$dpkgArch.asc" \
 && chmod +x /bin/tini /bin/tini.asc \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/2.*/gems/fluentd-*/test ruby-${RUBY_VER} ruby-${RUBY_VER}.tar.gz \
 && groupadd -g 5984 -r fluent && useradd -u 5984 -g fluent fluent \
 # for log storage (maybe shared with host)
 && mkdir -p /fluentd/log \
 # configuration/plugins path (default: copied from .)
 && mkdir -p /fluentd/etc /fluentd/plugins \
 && chown -R fluent /fluentd && chgrp -R fluent /fluentd

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 5140

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
