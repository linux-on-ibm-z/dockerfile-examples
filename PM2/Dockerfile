########## Dockerfile for PM2 version 2.10.1 #########
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
# docker run <container_name> -d -p <host_port>:<port> -v /<host_path_to_app>:/<container_path_to_app> <image-name> pm2 start <filename.js>
# e.g. docker run --name <container_name> -d -p 8080:8080 -v /root/test/pm2:/root <image-name> pm2 start --no-daemon /root/app.js
#	
# Official website: http://pm2.keymetrics.io/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Install dependencies
RUN  apt-get update  \
  && apt-get -y install \
         nodejs \
         npm  \
  && ln -s "$(which nodejs)" /usr/local/bin/node \
  && npm install pm2@2.10.1 -g \

# Clean up the unwanted packages and clear the source directory
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#  Expose port
EXPOSE 8080

CMD pm2

# End of Dockerfile
