# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################################### Dockerfile for Elasticsearch version 7.8.0 ########################################
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
FROM s390x/ubuntu:18.04

ARG ELASTICSEARCH_VER=7.8.0

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Set Environment Variables
ENV LANG="en_US.UTF-8"
ENV SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/usr/share/jdk-14.0.1+7
ENV JAVA14_HOME=/usr/share/jdk-14.0.1+7
ENV PATH=$JAVA_HOME/bin:$PATH
ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Elasticsearch/${ELASTICSEARCH_VER}/patch"
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
# Download AdoptOpenJDK 14
 && cd $SOURCE_DIR \
 && wget https://github.com/AdoptOpenJDK/openjdk14-binaries/releases/download/jdk-14.0.1%2B7/OpenJDK14U-jdk_s390x_linux_hotspot_14.0.1_7.tar.gz \
 && tar -C /usr/share/ -xzvf OpenJDK14U-jdk_s390x_linux_hotspot_14.0.1_7.tar.gz \
# Download and Build Elasticsearch
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v${ELASTICSEARCH_VER} \
 && wget $PATCH_URL/build.gradle  -P $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/archives/oss-linux-s390x-tar && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/archives/oss-linux-s390x-tar \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-deb && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-deb \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-deb && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-deb \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-rpm && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-oss-rpm \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/packages/s390x-rpm && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/packages/s390x-rpm \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-export && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-export \
 && mkdir -p $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-export && cp $SOURCE_DIR/elasticsearch/distribution/archives/linux-s390x-tar/build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-export \
 && wget $PATCH_URL/docker_build_context_build.gradle -P $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context \
 && mv $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context/docker_build_context_build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/docker-s390x-build-context/build.gradle \
 && wget $PATCH_URL/oss_docker_build_context_build.gradle -P $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context \
 && mv $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context/oss_docker_build_context_build.gradle $SOURCE_DIR/elasticsearch/distribution/docker/oss-docker-s390x-build-context/build.gradle \
 && wget -O - $PATCH_URL/diff.patch | git apply \
 && ./gradlew :distribution:archives:oss-linux-s390x-tar:assemble --parallel \
# Create distributions as deb, rpm and docker
 && ./gradlew :distribution:packages:s390x-oss-deb:assemble \
 && ./gradlew :distribution:packages:s390x-oss-rpm:assemble \
 && ./gradlew :distribution:docker:oss-docker-s390x-build-context:assemble \ 
# Install Elasticsearch
 && mkdir -p /usr/share/elasticsearch \
 && tar -xzf distribution/archives/oss-linux-s390x-tar/build/distributions/elasticsearch-oss-${ELASTICSEARCH_VER}-SNAPSHOT-linux-s390x.tar.gz -C /usr/share/elasticsearch --strip-components 1 \
 && ln -sf /usr/share/elasticsearch/bin/* /usr/bin/ \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    curl \
    git \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /root/.gradle/* /tmp/elasticsearch \
 && rm $SOURCE_DIR/OpenJDK14U-jdk_s390x_linux_hotspot_14.0.1_7.tar.gz \
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
