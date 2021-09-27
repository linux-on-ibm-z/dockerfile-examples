# © Copyright IBM Corporation 2018, 2021 
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Terraform - 1.0.7 ########################
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
FROM s390x/ubuntu:20.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG TERRAFORM_VERSION=1.0.7
ARG GO_VERSION=1.16.5

# Set PATH
ENV GOPATH=/root
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y git wget tar gcc && \
# Install go
    cd $GOPATH && \
    wget https://golang.org/dl/go${GO_VERSION}.linux-s390x.tar.gz && \
    tar -C /usr/local -xvzf go${GO_VERSION}.linux-s390x.tar.gz && \
# build Terraform
    mkdir -p $GOPATH/src/github.com/hashicorp && \
    cd $GOPATH/src/github.com/hashicorp && \
    git clone https://github.com/hashicorp/terraform.git && \
    cd terraform && \
    git checkout v${TERRAFORM_VERSION} && \
    go install .  && \
    mv ${GOPATH}/bin/terraform /usr/bin/

# Base Image
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

WORKDIR /root

COPY --from=builder /usr/bin/terraform /usr/bin/terraform

# Command to execute
ENTRYPOINT ["/usr/bin/terraform"]

# End of Dockerfile
