# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Apache Solr version 8.2.0 #########################
#
# To build Apache Solr image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start Apache Solr server run the below command
# docker run --name <container_name> -p <port_number>:8983 -d <image_name>
#
# To see the Admin Console, go to http://<hostname>:<port_number>/ on web browser.
#
####################################################################################
# Base image
FROM s390x/ubuntu:16.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Create a working directory for Apache Solr
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV JAVA_HOME=/opt/jdk-11.0.4+11 PATH=$JAVA_HOME/bin:$PATH

ARG SOLR_VER=8.2.0

# Install dependencies
RUN apt-get update &&   apt-get install -y \
    git \
    lsof \
    tar \
    wget \
# Download AdoptOpenJDK 11 with OpenJ9
 && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.4%2B11_openj9-0.15.1/OpenJDK11U-jdk_s390x_linux_openj9_11.0.4_11_openj9-0.15.1.tar.gz \
 && tar -xzf OpenJDK11U-jdk_s390x_linux_openj9_11.0.4_11_openj9-0.15.1.tar.gz -C /opt \
# Download Solr and build it
 && wget https://archive.apache.org/dist/lucene/solr/$SOLR_VER/solr-$SOLR_VER.tgz \
 && tar zxvf solr-$SOLR_VER.tgz  \
 && cd  $SOURCE_DIR/solr-$SOLR_VER/bin  \
 && chmod a+x solr  \
 && cp -r $SOURCE_DIR/solr-$SOLR_VER/ /opt/ \
 && mv /opt/solr-$SOLR_VER /opt/solr \
# Tidy and clean up
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    git \
    wget \
 && apt-get autoremove -y && apt autoremove -y \
 && apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* && rm -rf /var/tmp

# Port for Apache Solr
EXPOSE 8983

ENV PATH=$PATH:/opt/solr/bin

# Command to start sever
CMD ["solr","-f","-force"]
