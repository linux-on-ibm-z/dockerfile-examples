########## Dockerfile for PM2 version 2.6.0 #########
#
# This Dockerfile builds a basic installation of PM2.
#
# PM2 is a production process manager for Node.js applications with a built-in load balancer.
# It allows you to keep applications alive forever, to reload them without downtime and to facilitate common system admin tasks.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start PM2 using below command
# docker run <container_name> -it -p <host_port>:<port> -v /<host>:/root/data <image-name> start /data/<filename.js>
# e.g.  docker run --name pm2_test5521 -it -p 8080 -v /root:/root/data pm2_img start /root/data/app.js
#
#
# Official website: http://pm2.keymetrics.io/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x 
ENV PATH=$JAVA_HOME/bin:$PATH 

# Install dependencies
RUN  apt-get update  \
  && apt-get -y install curl \
	 nodejs \
	 npm  \
	 openjdk-8-jdk \
  && ln -s "$(which nodejs)" /usr/local/bin/node \
  && npm install pm2@2.6.0 -g \
  && apt-get remove -y \
     curl \
	 openjdk-8-jdk \
					
# Clean up the unwanted packages and clear the source directory 
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
  
VOLUME /data
EXPOSE 8080

ENTRYPOINT pm2

# End of Dockerfile
