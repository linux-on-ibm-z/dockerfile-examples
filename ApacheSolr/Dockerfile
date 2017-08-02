############### Dockerfile for Apache Solr version 6.6.0 #########################
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
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Create a working directory for Apache Solr
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x PATH=$JAVA_HOME/bin:$PATH

# Install dependencies
RUN apt-get update &&   apt-get install -y \
    ant \
    curl \
    lsof \
    openjdk-8-jdk \
    tar \
    wget \

# Download Solr and build it
 && wget http://archive.apache.org/dist/lucene/solr/6.6.0/solr-6.6.0-src.tgz \
 && tar zxvf solr-6.6.0-src.tgz  \
 && cd solr-6.6.0/solr \
 && ant ivy-bootstrap \
 && ant server \
 && cd  $SOURCE_DIR/solr-6.6.0/solr/bin  \
 && chmod a+x solr  \
 && cp -r $SOURCE_DIR/solr-6.6.0/solr /opt/ \

# Tidy and clean up 
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    ant \
    curl \
    lsof \
    wget \
 && apt-get autoremove -y && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp /var/tmp

# Port for Apache Solr
EXPOSE 8983

ENV PATH=$PATH:/opt/solr/bin

# Command to start sever
CMD ["solr","-f","-force"]
