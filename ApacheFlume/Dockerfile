########## Dockerfile for Apache flume-1.8 ##########
#
# Apache Flume is a distributed, reliable, and available service for
# efficiently collecting, aggregating, and moving large amounts of log data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is an example to use Apache_flume :
# docker run --name <container_name> --rm=true -v <path to configuration file in host>:<path to configuation file in container> -e FLUME_AGENT_NAME=<flume_agent_name> -e FLUME_CONF_FILE=/var/tmp/flume.conf -d <image_name>
# Example : docker run --name sample_container -v `pwd`/flume.conf:/root/flume.conf -e FLUME_AGENT_NAME=a1 -e FLUME_CONF_FILE=/root/flume.conf -p 2000:44444 -d apache_flume_ubuntu
#
# #################### flume.conf - sample apache flume configuration file  ###################
# #Name the components on this agent
#   a1.sources = r1
#   a1.sinks = k1
#   a1.channels = c1
#
# #Describe/configure the source
#   a1.sources.r1.type = netcat
#   a1.sources.r1.bind = 0.0.0.0
#   a1.sources.r1.port = 44444
#
# #Describe the sink
#   a1.sinks.k1.type = logger
#
# #Use a channel which buffers events in memory
#   a1.channels.c1.type = memory
#   a1.channels.c1.capacity = 1000
#   a1.channels.c1.transactionCapacity = 100
#
# #Bind the source and sink to the channel
#   a1.sources.r1.channels = c1
#   a1.sinks.k1.channel = c1
#################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Path configuration for apache flume
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x M2_HOME=/usr/share/maven MAVEN_OPTS="-Xms1024m -Xmx1024m -XX:MaxPermSize=1024m"
ENV PATH=$PATH:$JAVA_HOME:$JAVA_HOME/bin:$M2_HOME/bin:/usr/share/apache-flume-1.8.0/bin

# Install dependencies for Apache Flume
RUN apt-get update && apt-get install -y \
    ant \
    git \
    git-core \
    maven \
    openjdk-8-jdk \
    protobuf-compiler \
    tar \ 
    wget \
     
# Build Apache Flume
 && git clone -b flume-1.8 https://github.com/apache/flume.git  \
 && cd flume \
 && mvn install -DskipTests -Drat.numUnapprovedLicenses=100 \

# Copy it to /usr/share
 && cp -Rf /root/flume/flume-ng-dist/target/apache-flume-1.8.0-bin/apache-flume-1.8.0-bin /usr/share/apache-flume-1.8.0 \

# Clean up the unwanted packages and clear the source directory 
 && apt-get remove -y \
    ant \
    git \
    git-core \
    maven \
    protobuf-compiler \
    wget \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /root/.m2 /root/flume

# Expose the port 44444 as defined in configuration file flume.conf
EXPOSE 44444

# Command to start the apache flume agent
ENTRYPOINT flume-ng agent --conf conf --conf-file $FLUME_CONF_FILE --name $FLUME_AGENT_NAME -Dflume.root.logger=INFO,console

# End of Dockerfile
