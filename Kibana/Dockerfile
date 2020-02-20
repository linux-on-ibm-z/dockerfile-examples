# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

###################################### Dockerfile for Kibana version 7.5.1 ############################################
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

FROM s390x/ubuntu:18.04

ARG KIBANA_VER=7.5.1

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set Environment Variable
ENV PATH=/home/kibana/.yarn/bin:/home/kibana/.config/yarn/global/node_modules/.bin:/usr/share/kibana/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Kibana/${KIBANA_VER}/patch/"
# Set up Kibana user

RUN apt-get update && apt-get install sudo && groupadd -r kibana \
 && useradd -g kibana -m kibana \
 && echo "kibana ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER kibana
ENV WORKDIR=/home/kibana
# Install the dependencies
RUN sudo apt-get update && sudo apt-get install -y \
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
 && sudo mkdir -p /usr/local/lib/nodejs \
 && cd $WORKDIR && sudo wget https://nodejs.org/dist/v10.15.2/node-v10.15.2-linux-s390x.tar.gz \
 && sudo tar xzf node-v10.15.2-linux-s390x.tar.gz -C /usr/local/lib/nodejs \
 && sudo ln -s /usr/local/lib/nodejs/node-v10.15.2-linux-s390x/bin/* /usr/bin/ \
# Install Yarn
 && curl -o- -L https://yarnpkg.com/install.sh | bash \
# Download and Install Kibana
 && cd $WORKDIR && git clone -b v${KIBANA_VER} https://github.com/elastic/kibana.git \
 && cd kibana \
# Apply Kibana patch
 && curl -o kibana_patch.diff $PATCH_URL/kibana_patch.diff \
 && git apply kibana_patch.diff \
# Bootstrap Kibana
 && yarn kbn bootstrap --oss \
 && yarn build --skip-os-packages --oss \
 && sudo mkdir /usr/share/kibana/ \
 && sudo tar xzf target/kibana-oss-${KIBANA_VER}-SNAPSHOT-linux-x86_64.tar.gz -C /usr/share/kibana --strip-components 1 \
 && sudo chown kibana:kibana -R /usr/share/kibana/ \
# Cleanup Cache data, unused packages and source files
&& sudo apt-get remove -y \
    curl \
    git \
    g++ \
    wget \
 && sudo apt-get autoremove -y && sudo apt-get clean \
 && sudo rm -rf $WORKDIR/kibana* $WORKDIR/node-v10.15.2-linux-s390x.tar.gz \
 && sudo rm -rf /var/lib/apt/lists/* $HOME/.cache
# Expose 5601 port used by Kibana
EXPOSE 5601

ENV PATH=/usr/share/kibana/bin:$PATH
ENV KIBANA_HOME=/usr/share/kibana/

# Start Kibana service
CMD ["kibana","-H","0.0.0.0"]
