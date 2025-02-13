# © Copyright IBM Corporation 2023, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
########## Dockerfile for Terraform - 1.10.4 ########################
#
# Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently.
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
# Running Terraform inside a Docker container requires more configuration than running the Terraform CLI executables directly. Unless you need container isolation, the non-containerized Terraform CLI binary is recommended.
#
# Reference:
# https://www.terraform.io/
# https://hub.docker.com/r/hashicorp/terraform/
#
#####################################################################

FROM docker.mirror.hashicorp.services/golang:alpine AS builder
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG TERRAFORM_VERSION=v1.10.5
RUN apk add --no-cache git bash openssh \
    && git clone -b ${TERRAFORM_VERSION} https://github.com/hashicorp/terraform.git /go/src/github.com/hashicorp/terraform
ENV TF_DEV=true
ENV TF_RELEASE=1
WORKDIR /go/src/github.com/hashicorp/terraform
RUN /bin/bash ./scripts/build.sh
FROM docker.mirror.hashicorp.services/alpine:latest
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG BIN_NAME=terraform
COPY --from=builder /go/bin/terraform /bin/terraform
COPY --from=builder /go/src/github.com/hashicorp/terraform/LICENSE /usr/share/doc/${BIN_NAME}/LICENSE.txt
WORKDIR /go
ENTRYPOINT ["/bin/terraform"]
