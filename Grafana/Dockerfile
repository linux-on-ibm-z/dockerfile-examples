############################ Dockerfile for Grafana4.4.1 ############################################
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
# docker run --name <container_name> -v <path_to_grafana_config_file>:/opt/src/github.com/grafana/grafana/conf/custom.ini -p <port>:3000 -d <image_name>
# More information in the grafana configuration documentation: http://docs.grafana.org/installation/configuration/
################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source
ENV GOPATH=/opt
ENV QT_QPA_PLATFORM=offscreen
ENV PATH=$PATH:/opt/dist/bin
ENV PATH=$PATH:$GOPATH/bin
ENV PATH=$PATH:/opt/ibm/node/bin
ENV PATH=$PATH:/usr/local/go/bin

WORKDIR $SOURCE_DIR

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

# Install Nodejs
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/nodejs/6.10.0.0/linux/s390x/ibm-6.10.0.0-node-v6.10.0-linux-s390x.bin \
 && chmod +x ibm-6.10.0.0-node-v6.10.0-linux-s390x.bin \
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
 && ./ibm-6.10.0.0-node-v6.10.0-linux-s390x.bin -i silent \

# Install Golang
 && cd $SOURCE_DIR \
 && wget https://storage.googleapis.com/golang/go1.8.3.linux-s390x.tar.gz \
 && chmod +x go1.8.3.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.8.3.linux-s390x.tar.gz \
 && go version \


# Get the Grafana Soure code and build Grafana backend
 && git clone https://github.com/grafana/grafana.git $GOPATH/src/github.com/grafana/grafana \
 && cd $GOPATH/src/github.com/grafana/grafana && git checkout v4.4.1 \
 && cd ./vendor/github.com/klauspost/compress/gzip \
 && cp gunzip.go gunzip.go.copy \
 && cp gzip.go gzip.go.copy \


# Edit the file vendor/github.com/klauspost/compress/gzip/gunzip.go
 && sed -i '17d ' gunzip.go \
 && sed -i "17 i \\\t\"hash/crc32\"" gunzip.go \

# Edit the file vendor/github.com/klauspost/compress/gzip/gzip.go
 && sed -i '14d ' gzip.go \
 && sed -i "14 i \\\t\"hash/crc32\"" gzip.go \
 && cd $GOPATH/src/github.com/grafana/grafana \
 && make deps-go \
 && make build-go \

# Install yarn
 && cd $SOURCE_DIR && wget https://yarnpkg.com/latest.tar.gz \
 && tar -C /opt/ -xzf latest.tar.gz \

# Install grunt
 && cd $GOPATH/src/github.com/grafana/grafana \
 &&  npm install grunt \

# Build frontend
 && make deps-js \
 && make build-js \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    build-essential \
    gcc \
    git \
    make \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \

WORKDIR /opt/src/github.com/grafana/grafana

VOLUME ["/opt/src/github.com/grafana/grafana/conf","/opt/src/github.com/grafana/grafana/data"]

EXPOSE 3000

ENTRYPOINT grafana-server -homepath=/opt/src/github.com/grafana/grafana/ start
