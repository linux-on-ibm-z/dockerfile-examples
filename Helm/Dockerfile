# © Copyright IBM Corporation 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
######################### Dockerfile for Helm version 3.0.0 #####################################################
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
FROM s390x/ubuntu:16.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:/usr/local/go/bin/:$GOPATH/bin
#Install dependencies
RUN apt-get update -y && apt-get install -y make wget bash git socat gcc \
#Get Helm
&& wget https://dl.google.com/go/go1.13.4.linux-s390x.tar.gz \
&& chmod ugo+r go1.13.4.linux-s390x.tar.gz \
&& tar -C /usr/local -xzf go1.13.4.linux-s390x.tar.gz \
&& mkdir -p $GOPATH/src/helm.sh \
&& cd $GOPATH/src/helm.sh \
&& git clone https://github.com/kubernetes/helm.git \
&& cd helm \
&& git checkout v3.0.0 \
&& make \
&& mkdir -p $GOPATH/bin \
&& cp bin/helm $GOPATH/bin \
&& apt-get remove -y \
        wget \
        make \
        git \
&& apt-get autoremove -y \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& rm -rf /src/helm.sh
EXPOSE 44134
ENV HELM_HOST=localhost:44134
CMD ["helm"]
#End of Dockerfile
