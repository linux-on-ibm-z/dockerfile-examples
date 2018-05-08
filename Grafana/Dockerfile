# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Grafana 5.1.0 ############################################
#
# This Dockerfile builds a basic installation of Grafana.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Grafana service using this image, use following command:
# docker run --name <container name> -p <port>:3000 -d <image name>
#
# To start the Grafana service by providing configuration
# docker run --name <container_name> -v <path_to_grafana_config_file>:/usr/share/grafana/conf/custom.ini -p <port>:3000 -d <image_name>
# More information in the grafana configuration documentation: http://docs.grafana.org/installation/configuration/
################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV QT_QPA_PLATFORM=offscreen GOPATH=/opt
ENV PATH=$PATH:/opt/yarn-v1.3.2/bin:$GOPATH/bin:/opt/ibm/node/bin:/usr/lib/go-1.10/bin:/usr/share/grafana

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    gcc \
    git \
    make \
    openjdk-8-jdk \
    phantomjs \
    python \
    wget \
    unzip \
    golang-1.10 \
	
# Install Nodejs
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/nodejs/8.9.4.0/linux/s390x/ibm-8.9.4.0-node-v8.9.4-linux-s390x.bin \
 && chmod +x ibm-8.9.4.0-node-v8.9.4-linux-s390x.bin \
 && echo "#Indicate whether the license agreement been accepted" >installer.properties \
 && echo  "#----------------------------------------------------" >> installer.properties \
 && echo "LICENSE_ACCEPTED=TRUE">> installer.properties \
 && echo "#Choose Install Folder" >> installer.properties \
 && echo "#---------------------" >> installer.properties \
 && echo "USER_INSTALL_DIR=/opt/ibm/node" >> installer.properties \
 && echo "#Choose Link Location" >> installer.properties \
 && echo "#--------------------" >> installer.properties \
 && echo "USER_SHORTCUTS=/opt" >> installer.properties \
 && echo "#Install" >> installer.properties \
 && echo "#-------" >> installer.properties \
 && echo "-fileOverwrite_/home/test/ibm/node/_node_installation/uninstall.lax=Yes" >> installer.properties \
 && ./ibm-8.9.4.0-node-v8.9.4-linux-s390x.bin -i silent \


# Get the Grafana Soure code and build Grafana backend
 && cd / && git clone https://github.com/grafana/grafana.git $GOPATH/src/github.com/grafana/grafana \
 && cd $GOPATH/src/github.com/grafana/grafana && git checkout v5.1.0 \
 && make deps-go \
 && make build-go \

# Install yarn
 && cd / && wget https://github.com/yarnpkg/yarn/releases/download/v1.3.2/yarn-v1.3.2.tar.gz \
 && tar -C /opt/ -xzf yarn-v1.3.2.tar.gz \
 && rm -rf /yarn-v1.3.2.tar.gz \

# Install grunt
 && cd $GOPATH/src/github.com/grafana/grafana \
 && npm install grunt \

# Build frontend
 && make deps-js \
 && make build-js \

# Copy it to /usr/share
 && cp -Rf $GOPATH/src/github.com/grafana/grafana /usr/share/ \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    build-essential \
    gcc \
    git \
    make \
    phantomjs \
    python \
    wget \
    unzip \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  $GOPATH/src/github.com  /ibm-6.11.5.0-node-v6.11.5-linux-s390x.bin \
 && sh "/opt/Uninstall IBM SDK for Node.js (TM)"
 
VOLUME ["/usr/share/grafana/conf","/usr/share/grafana/data"]

EXPOSE 3000
WORKDIR "/usr/share/grafana/"


ENTRYPOINT grafana-server start
