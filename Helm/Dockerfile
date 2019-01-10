# © Copyright IBM Corporation 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################### Dockerfile for Helm version 2.11.0 #####################################################
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
# docker run --name <container_name> -d <image_name>

#########################################################################################################################


#Base image
FROM s390x/ubuntu:16.04

#Set Environment Variables
ENV GOPATH=/go PATH=/usr/lib/go-1.9/bin:$GOPATH/linux-s390x:$PATH

#Install dependencies
RUN apt-get update -y &&   apt-get install -y git make mercurial wget golang-1.9 bash\

#Install glide
&& wget https://github.com/Masterminds/glide/releases/download/v0.13.0/glide-v0.13.0-linux-s390x.tar.gz \
&&  tar -xzf glide-v0.13.0-linux-s390x.tar.gz && rm -rf glide-v0.13.0-linux-s390x.tar.gz \

#Build Helm
&&  mkdir -p $GOPATH/src/k8s.io \
&&  cd $GOPATH/src/k8s.io \
&&  git clone https://github.com/kubernetes/helm.git \
&&  cd helm \
&&  git checkout v2.11.0 \
&&  cd $GOPATH/src/k8s.io/helm \
&&  make bootstrap build \
&&  cp -Rf  $GOPATH/src/k8s.io/helm /helm \
&&  cd /helm/bin \
# Clean up cache , source data and un-used packages
&& apt-get remove -y \
        git \
        make \
        wget \
        mercurial \
        golang-1.9 \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf $GOPATH
EXPOSE 44134
ENV  PATH=/helm/bin:$PATH  HELM_HOST=localhost:44134
CMD ["tiller"]
#End of Dockerfile
