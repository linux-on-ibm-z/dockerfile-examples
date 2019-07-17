# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 7.2.0 ############################################
#
# This Dockerfile builds a basic installation of Kibana.
#
# Kibana is an open source data visualization plugin for Elasticsearch.
# It provides visualization capabilities on top of the content indexed on an Elasticsearch cluster.
# Users can create bar, line and scatter plots, or pie charts and maps on top of large volumes of data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Kibana container using the below command.
# docker run --name <container_name> -p 5601:5601 -d <image_name>
#
# Start Kibana using sample kibana.yml file using below command.
# docker run --name <container_name> -v <path_on_host>/kibana.yml:/etc/kibana/kibana.yml -p 5601:5601 -d <image_name>
#
# To see the Kibana UI, go to http://<hostname>:<port_number>/ on web browser.
#
##############################################################################################################

FROM s390x/ubuntu:16.04

ARG KIBANA_VER=7.2.0

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

WORKDIR "/tmp"

# Set Environment Variable
ENV PATH=/home/kibana/.yarn/bin:/home/kibana/.config/yarn/global/node_modules/.bin:/usr/share/kibana/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/{ELASTICSEARCH_VER}/patch/"

# Set up Kibana user
RUN groupadd -r kibana \
 && useradd -g kibana -m kibana \
 && mkdir -p /usr/share/kibana \
 && chown kibana:kibana -R /usr/share/kibana \

# Install the dependencies
 && apt-get update && apt-get install -y \
    curl \
    git \
    g++ \
    gzip \
    libssl-dev \
    make \
    python \
    sudo \
    tar \
    wget \

# Installing Node.js v10.15.2
 && mkdir -p /usr/local/lib/nodejs \
 && wget https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-s390x.tar.gz \
 && tar xzf node-v10.15.2-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
 && ln -s /usr/local/lib/nodejs/node-v10.15.2-linux-s390x/bin/* /usr/bin/

USER kibana

# Install Yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash \

# Download and Install Kibana
 && git clone -b v${KIBANA_VER} https://github.com/elastic/kibana.git \
 && cd kibana \

# Apply Kibana patch
 && curl -o kibana_patch.diff $PATCH_URL/kibana_patch.diff \
 && git apply kibana_patch.diff \

# Bootstrap Kibana
 && yarn kbn bootstrap --oss \

# Install Elasticsearch Nodegit
 && cd node_modules/@elastic/ \
 && git clone https://github.com/elastic/nodegit.git \
 && cd nodegit \
 && git checkout v0.25.0-alpha.20 \

# Apply Nodegit patch
 && curl -o nodegit_patch.diff $PATCH_URL/nodegit_patch.diff \
 && git apply nodegit_patch.diff \ 

 && npm install \

 && cd /tmp/kibana \
 && yarn build --skip-os-packages --oss \
 && tar -xzf target/kibana-oss-${KIBANA_VER}-SNAPSHOT-linux-x86_64.tar.gz -C /usr/share/kibana --strip-components 1 \

USER root

# Cleanup Cache data, unused packages and source files
 && apt-get remove -y \
    curl \
    git \
    g++ \
    wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /tmp/kibana* /tmp/node-v10.15.2-linux-s390x.tar.gz \
 && rm -rf /var/lib/apt/lists/*

USER kibana

# Expose 5601 port used by Kibana
EXPOSE 5601

ENV PATH=/usr/share/kibana/bin:$PATH
ENV KIBANA_HOME=/usr/share/kibana/

# Start Kibana service
CMD ["kibana","-H","0.0.0.0"]
