# © Copyright IBM Corporation 2019, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
######################### Dockerfile for Helm version 3.1.2 #####################################################
#
# This Dockerfile builds a basic installation of Helm.
#
# Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Helm use following command:
# docker run -it --name <container_name> <image_name>
#########################################################################################################################

#Base image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ARG VERSION=3.1.2
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

RUN apt-get update -y && apt-get install -y wget tar \
#Get Helm
&& wget https://get.helm.sh/helm-v${VERSION}-linux-s390x.tar.gz \
&& chmod ugo+r helm-v${VERSION}-linux-s390x.tar.gz \
&& tar -xzf helm-v${VERSION}-linux-s390x.tar.gz \
&& mv linux-s390x/helm /usr/bin/helm \
&& chmod +x /usr/bin/helm \
&& rm -rf linux-s390x

ENTRYPOINT ["helm"]
CMD ["--help"]
#End of Dockerfile
