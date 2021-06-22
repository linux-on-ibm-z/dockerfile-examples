# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################### Dockerfile for PM2 latest version ##############################
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
# docker run --name <container_name> -d -p <host_port>:<port> -v /<host_path_to_app>:/<container_path_to_app> <image-name> pm2-runtime start <filename.js>
# e.g. docker run --name <container_name> -d -p 8080:8080 -v /root/test/pm2:/root <image-name> pm2-runtime start /root/app.js
#
# Official website: http://pm2.keymetrics.io/
#
###################################################################################

# Base image
FROM node:16.3.0-alpine

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN npm install pm2 -g

EXPOSE 8080

CMD pm2-runtime
