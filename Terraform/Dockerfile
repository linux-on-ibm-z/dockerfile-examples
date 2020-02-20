# © Copyright IBM Corporation 2018, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Terraform - 0.12.20 ########################
#
# Terraform is a tool for building, changing, and combining infrastructure safely and efficiently.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To see the Usage of Terraform resultant image, Use below command:
# docker run -it --name <container_name> <image_name> -help
#
# Below is an example to run Terraform console :
# docker run -it --name <container_name> <image_name> console
#
# Reference: https://www.terraform.io/
#####################################################################

# Base image
FROM s390x/ubuntu:16.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG TERRAFORM_VER=0.12.20

# Set environment variables
ENV SOURCE_DIR=/source
WORKDIR $SOURCE_DIR
ENV GOPATH $SOURCE_DIR
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
  
# Installing dependencies for Terraform
RUN apt-get update &&  apt-get install -y \
    gcc \
    git \
    make \
    tar \
    wget \
    zip \
# Install Go
 && cd $SOURCE_DIR \
 && wget https://dl.google.com/go/go1.12.9.linux-s390x.tar.gz \
 && chmod ugo+r go1.12.9.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.12.9.linux-s390x.tar.gz \
# Clone Terraform Source Code
 && cd $SOURCE_DIR \
 && mkdir -p $GOPATH/src/github.com/hashicorp \
 && cd $GOPATH/src/github.com/hashicorp \
 && git clone https://github.com/hashicorp/terraform.git \
 && cd terraform && git checkout v${TERRAFORM_VER} \
 && export GO111MODULE=on \
 && export GOPROXY=https://proxy.golang.org/ \
# Build Terraform
 && XC_OS=linux XC_ARCH=s390x make bin \
 && mv ${GOPATH}/src/github.com/hashicorp/terraform/pkg/linux_s390x/terraform /usr/bin/ \
# Tidy and clean up
 && apt-get remove -y \
    gcc \
    git \
    make \
    wget \
    zip \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* $GOPATH/src $GOPATH/pkg $SOURCE_DIR/go1.12.9.linux-s390x.tar.gz

# Base Image
FROM s390x/ubuntu:16.04

WORKDIR /root
COPY --from=builder /usr/bin/terraform /usr/bin/terraform
# Port for cAdvisor
EXPOSE 8080

# Command to execute
ENTRYPOINT ["/usr/bin/terraform"]

# End of Dockerfile
