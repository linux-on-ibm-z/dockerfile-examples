# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################ Dockerfile for Docker Compose version 1.21.0 ####################
#
# This Dockerfile builds a basic installation of Docker Compose.
#
# Docker Compose is a tool for defining and running multi-container Docker applications.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Docker compose container,from the directory containing docker-compose.yml or docker-compose.yaml file
# docker run --name <container_name> -i -t -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:`pwd` -w `pwd` <image_name> up -d
# or
# docker run --name <container_name> -i -t -v /var/run/docker.sock:/var/run/docker.sock -v <path_on_host>/docker-compose.yml:<path_on_container>/docker-compose.yml -w <path_on_container>  <image_name> up -d
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Install dependencies and Docker Compose
RUN apt-get update && apt-get install -y \
    python-pip \
 && pip install docker-compose==1.21.0 \
 
# Clean up unused packages and data
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/docker-compose"]
# End of Dockerfile
