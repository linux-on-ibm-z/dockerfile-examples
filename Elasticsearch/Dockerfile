# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################### Dockerfile for Elasticsearch version 6.2.4 ##################################
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
# Start Elastic search with configurtion file
# For ex. docker run --name <container_name> -v <path_on_host>/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml -p <port>:9200 -d <image_name>
#
##############################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

# The Author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment Variables

ENV LANG="en_US.UTF-8" JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8" _JAVA_OPTIONS="-Xmx10g" SOURCE_DIR="/tmp/"
ENV JAVA_HOME=/usr/share/jdk-9+181
ENV PATH=$JAVA_HOME/bin:$PATH
WORKDIR $SOURCE_DIR

# Install Dependencies
RUN apt-get update &&  apt-get install -y \
    ant \
    autoconf \
    automake \
    curl \
    git \
    libtool \
    libx11-dev \
    libxt-dev \
    locales-all \
    make \
    maven \
    patch \
    pkg-config \
    tar \
    texinfo \
    unzip \
    wget \
    sudo \

# Download AdoptJDK
 && cd $SOURCE_DIR \
 && wget https://github.com/AdoptOpenJDK/openjdk9-releases/releases/download/jdk-9%2B181/OpenJDK9_s390x_Linux_jdk-9.181.tar.gz \
 && tar -C /usr/share/ -xvf OpenJDK9_s390x_Linux_jdk-9.181.tar.gz \ 
	
# Download and build source code of elastic search
 && cd $SOURCE_DIR && git clone https://github.com/elastic/elasticsearch && cd elasticsearch && git checkout v6.2.4 \
 && sed -i '244a m.put("s390x", new Arch(0x80000016, 0xFFFFFFFF, 1, 190, 11, 354, 348));' $SOURCE_DIR/elasticsearch/server/src/main/java/org/elasticsearch/bootstrap/SystemCallFilter.java \
 && ./gradlew assemble \
 && cd $SOURCE_DIR/elasticsearch/distribution/tar/build/distributions/ \
 && tar -C /usr/share/ -xf elasticsearch-6.2.4-SNAPSHOT.tar.gz \
 && mv /usr/share/elasticsearch-6.2.4-SNAPSHOT /usr/share/elasticsearch \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    ant \
    automake \
    git \
    maven \
    patch \
    pkg-config \
    unzip \
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
