# © Copyright IBM Corporation 2018, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Terraform - 0.13.4 ########################
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
FROM golang:1.14.7-alpine AS builder

ENV TERRAFORM_VERSION=0.13.4

RUN apk add --update git bash openssh

ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform

RUN git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh && \
    mv ${GOPATH}/src/github.com/hashicorp/terraform/pkg/linux_s390x/terraform /usr/bin/

# Base Image
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

WORKDIR /root

COPY --from=builder /usr/bin/terraform /usr/bin/terraform

# Command to execute
ENTRYPOINT ["/usr/bin/terraform"]

# End of Dockerfile
