########## Dockerfile for Apache ActiveMQ version 5.15.0 #########
#
# This Dockerfile builds a basic installation of Apache Hbase.
#
# Apache ActiveMQ is the most popular and powerful open source messaging and Integration Patterns server.
# Apache ActiveMQ is fast, supports many Cross Language Clients and Protocols, comes with easy to use Enterprise Integration Patterns and many advanced features while fully supporting JMS 1.1 and J2EE 1.4.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start Apacahe ActiveMQ server using below command:
# docker run <container_name> -it  -v /<host>:/<container> <image-name>  activemq <command>
# e.g. docker run --name activemq -it -v /root:/root/ activemq_img  activemq start
# 
# Official website: http://activemq.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x 
ENV ACTIVEMQ_HOME=/opt/activemq
ENV MAVEN_OPTS='-Xmx1024m'
ENV PATH=$PATH:$JAVA_HOME/bin:$ACTIVEMQ_HOME/bin
ENV SOURCE_DIR='/root'
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install -y \
			git \
            maven \
			openjdk-8-jdk \
	        
# Download and build source code of Apache Hbase
  && cd $SOURCE_DIR \
  && git clone -b activemq-5.15.0 https://github.com/apache/activemq.git \
  && cd activemq \
  && mvn clean install -Dmaven.test.skip=true \
  && mkdir -p /opt/activemq \
  && cd $SOURCE_DIR/ \
  && tar -xzf ~/.m2/repository/org/apache/activemq/apache-activemq/5.15.0/apache-activemq-5.15.0-bin.tar.gz \
  && cp -a $SOURCE_DIR/apache-activemq-5.15.0/* /opt/activemq \
  
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
  			 git \
		     maven \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/activemq $SOURCE_DIR/apache-activemq-5.15.0 /var/lib/apt/lists/* /root/.m2 

VOLUME /data

EXPOSE 8161 61616

# start activemq 
CMD activemq 

# End of Dockerfile
