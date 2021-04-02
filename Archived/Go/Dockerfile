# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
# This dockerfile is no longer supported. Please find latest information from https://www.ibm.com/community/z/open-source-software/
#
########################## Dockerfile for Go version 1.11.4 #######################
# This Dockerfile builds a basic installation of go and its configuration.
#
# Go is an open source programming language that makes it easy to build simple, reliable, and efficient software.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start a container with Go image.
# docker run --name <container_name> -it <image_name> /bin/bash
#
# To use go image from command line, use following command:
# docker run --rm=true --name <container_name> -it <image_name> go <argument>
# For ex. docker run --rm=true --name <container_name> -it <image_name> go --help
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y wget tar && \
    mkdir -p /go && cd /go && wget https://storage.googleapis.com/golang/go1.11.4.linux-s390x.tar.gz && \
    chmod ugo+r go1.11.4.linux-s390x.tar.gz && \
    tar -C /usr/local -xzf go1.11.4.linux-s390x.tar.gz && \

# Tidy up (Clear cache data)
    rm -rf go1.11.4.linux-s390x.tar.gz && \
    apt-get clean
  

# Dockerfile does not have a CMD statement as the image is intended to be
# used as a base image for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
