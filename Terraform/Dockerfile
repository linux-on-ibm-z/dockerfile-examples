# © Copyright IBM Corporation 2018
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Terraform - 0.11.10 ########################
# 
# Terraform is a tool for building, changing, and combining infrastructure safely and efficiently.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container_name> -it <image_name> /bin/bash
#
#
# Below is an example to run Terraform console :
# docker run --name <container_name> -it <image_name> terraform console
#
# Reference: https://www.terraform.io/
#####################################################################

# Base image
FROM s390x/ubuntu:16.04

ARG TERRAFORM_VER=0.11.10

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set environment variables
ENV SOURCE_DIR=/source
WORKDIR $SOURCE_DIR
ENV GOPATH $SOURCE_DIR
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Installing dependencies for Terraform
RUN apt-get update &&  apt-get install -y \
    git  \
    make \
    zip  \
	wget \
    tar \
	gcc \
# Install Go
 && wget https://storage.googleapis.com/golang/go1.11.4.linux-s390x.tar.gz \
 && chmod ugo+r go1.11.4.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.11.4.linux-s390x.tar.gz \ 
# Clone Terraform Source Code
 && cd $SOURCE_DIR \
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/terraform.git \
 && cd terraform && git checkout v${TERRAFORM_VER} \
 && make tools \
# Build Terraform
 && XC_OS=linux XC_ARCH=s390x make bin \
# Tidy and clean up
 && apt-get remove -y \
    git \
    wget \
    zip \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["terraform"]

# End of Dockerfile
