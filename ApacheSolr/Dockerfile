# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Apache Solr version 8.1.1 #########################
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
ENV JAVA_HOME=/opt/jdk8u212-b04 PATH=$JAVA_HOME/bin:$PATH

ARG SOLR_VER=8.1.1

# Install dependencies
RUN apt-get update &&   apt-get install -y \
    ant \
    curl \
    git \
    lsof \
    tar \
    wget \

# Download AdoptOpenJDK 8 with OpenJ9
 && wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u212-b04_openj9-0.14.2/OpenJDK8U-jdk_s390x_linux_openj9_8u212b04_openj9-0.14.2.tar.gz \
 && tar -xzf OpenJDK8U-jdk_s390x_linux_openj9_8u212b04_openj9-0.14.2.tar.gz -C /opt \

# Download Solr and build it
 && wget http://archive.apache.org/dist/lucene/solr/$SOLR_VER/solr-$SOLR_VER-src.tgz \
 && tar zxvf solr-$SOLR_VER-src.tgz  \
 && cd solr-$SOLR_VER/solr \
 && ant ivy-bootstrap \
 && ant server \
 && cd  $SOURCE_DIR/solr-$SOLR_VER/solr/bin  \
 && chmod a+x solr  \
 && cp -r $SOURCE_DIR/solr-$SOLR_VER/solr /opt/ \

# Tidy and clean up 
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    ant \
    curl \
    git \
    wget \
 && apt-get autoremove -y && apt autoremove -y \
 && apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* && rm -rf /var/tmp

# Port for Apache Solr
EXPOSE 8983

ENV PATH=$PATH:/opt/solr/bin

# Command to start sever
CMD ["solr","-f","-force"]
