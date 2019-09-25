# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################################### Dockerfile for Elasticsearch version 7.3.0 ########################################
#
# This Dockerfile builds a basic installation of Elasticsearch.
#
# Elasticsearch is a search server based on Lucene. It provides a distributed, multitenant-capable
# full-text search engine with an HTTP web interface and schema-free JSON documents.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Elasticsearch container using the below command
# docker run --name <container_name> -p 9200:9200 -d <image_name>
#
# Start Elastic search with configuration file
# For ex. docker run --name <container_name> -v <path_on_host>/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -p <port>:9200 -d <image_name>
#
##############################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

ARG ELASTICSEARCH_VER=7.3.0

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set Environment Variables
ENV LANG="en_US.UTF-8"
ENV SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/usr/share/jdk-12.0.2+10
ENV PATH=$JAVA_HOME/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Elasticsearch/${ELASTICSEARCH_VER}/patch/"
WORKDIR $SOURCE_DIR

# Install Dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    gzip \
    tar \
    wget \
# Set up locale
 && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
# Download AdoptOpenJDK 12
 && cd $SOURCE_DIR \
 && wget https://github.com/AdoptOpenJDK/openjdk12-binaries/releases/download/jdk-12.0.2%2B10/OpenJDK12U-jdk_s390x_linux_hotspot_12.0.2_10.tar.gz \
 && tar -C /usr/share/ -xzvf OpenJDK12U-jdk_s390x_linux_hotspot_12.0.2_10.tar.gz \
# Download and Build Elasticsearch
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v${ELASTICSEARCH_VER} \
 && curl -o patch_gradle.diff $PATCH_URL/patch_gradle.diff \
 && patch $SOURCE_DIR/elasticsearch/distribution/archives/build.gradle patch_gradle.diff \
 && ./gradlew -p distribution/archives/oss-linux-tar assemble --parallel \
# Install Elasticsearch
 && mkdir -p /usr/share/elasticsearch \
 && tar -xzf distribution/archives/oss-linux-tar/build/distributions/elasticsearch-oss-${ELASTICSEARCH_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/elasticsearch --strip-components 1 \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    curl \
    git \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /root/.gradle/* /tmp/elasticsearch \
# Create elaticsearch user
 && /usr/sbin/groupadd elasticsearch \
 && /usr/sbin/useradd -g elasticsearch elasticsearch \
 && usermod -aG sudo elasticsearch \
 && chown elasticsearch:elasticsearch -R /usr/share/elasticsearch
 
# Expose the default port
USER elasticsearch

EXPOSE 9200 9300

ENV PATH=/usr/share/elasticsearch/bin:$PATH

# Start the elasticsearch server
CMD ["elasticsearch"]

# End of Dockerfile
