########################## Dockerfile for Go version 1.8.1 ######################
#
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
################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install dependencies and extract go binary
RUN apt-get update && apt-get install -y \
    tar \
    wget \
 && mkdir -p /go && cd /go && wget https://storage.googleapis.com/golang/go1.8.1.linux-s390x.tar.gz \
 && chmod ugo+r go1.8.1.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.8.1.linux-s390x.tar.gz \

# Tidy up (Clear cache data)
 && rm -rf go1.8.1.linux-s390x.tar.gz \
 && apt-get remove -y wget \
 && apt-get autoremove -y  && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Dockerfile does not have a CMD statement as the image is intended to be
# used as a base image for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
