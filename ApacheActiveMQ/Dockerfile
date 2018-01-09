########## Dockerfile for Apache ActiveMQ version 5.15.2 #########
#
# This Dockerfile builds a basic installation of Apache ActiveMQ.
#
# Apache ActiveMQ is the most popular and powerful open source messaging and Integration Patterns server.
# Apache ActiveMQ is fast, supports many Cross Language Clients and Protocols, comes with easy to use Enterprise Integration Patterns and many advanced features while fully supporting JMS 1.1 and J2EE 1.4.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Run the ActiveMQ Message Broker using below command:
# docker run --name <container_name> -d -p <port>:8161 <image-name>
# e.g. docker run --name activemq -d -p 8161:8161 activemq:5.15.2
#
# To provide custom configuration for Activemq use below command:
#  docker run --name <container_name> -d -p <port>:8161 -v /<host_path>/conf:/opt/activemq/conf <image-name>
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
	        
# Download and build source code of Apache ActiveMQ
  && cd $SOURCE_DIR \
  && git clone -b activemq-5.15.2 https://github.com/apache/activemq.git \
  && cd activemq \
  && mvn clean install -Dmaven.test.skip=true \
  && mkdir -p /opt/activemq \
  && cd $SOURCE_DIR/ \
  && tar -xzf ~/.m2/repository/org/apache/activemq/apache-activemq/5.15.2/apache-activemq-5.15.2-bin.tar.gz \
  && cp -a $SOURCE_DIR/apache-activemq-5.15.2/* /opt/activemq \
  
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
  			 git \
		     maven \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/activemq $SOURCE_DIR/apache-activemq-5.15.2 /var/lib/apt/lists/* /root/.m2 

# Define mount point having important data like pid, log & db info 
VOLUME ["/opt/activemq/data"]

# Expose default Port for HTTP & Openwire 
EXPOSE 8161 61616


# Start activemq 
CMD ["activemq","console"]

# End of Dockerfile
