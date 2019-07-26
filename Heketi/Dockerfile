# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################### Dockerfile for Heketi 9.0.0 ########################
#
# This Dockerfile builds a basic installation of heketi.
#
# Heketi is RESTful based volume management framework for GlusterFS
#
# docker build -t <image_name> .
#
# Server Setup :
#  Create the configuration and pass it to heketi
#  mkdir -p heketi/config
#  mkdir -p heketi/db
#  cp heketi.json heketi/config
#  cp myprivate_key heketi/config
#  Use below command to pass the configuration using volume and start the heketi service
#  docker run  --name <container_name> -v $PWD/heketi/config:/etc/heketi -v $PWD/heketi/db:/var/lib/heketi -p 8080:8080 -d <image_name>
#
# Using heketi-cli :
# below command will display the hekecli help option
# docker exec <container_name> heketi-cli -h
###########################################################################

# Base image
FROM s390x/ubuntu:16.04

# Maintainer
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG HEKETI_VERSION=v9.0.0

ENV GOPATH=/build
ENV PATH=$PATH:/usr/lib/go-1.10/bin:$GOPATH/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git  \
    golang-1.10 \
    make \
    mercurial \
    tar \
    wget \
    patch \
    curl \

# Setup directories
 && mkdir -p /etc/heketi /var/lib/heketi $GOPATH/bin $GOPATH/src/github.com/heketi \

# Install glide
 && cd $GOPATH/bin \
 && wget https://github.com/Masterminds/glide/releases/download/v0.13.1/glide-v0.13.1-linux-s390x.tar.gz \
 && tar -xzf glide-v0.13.1-linux-s390x.tar.gz linux-s390x/glide --strip=1 \

# Clone and build heketi source
 && cd $GOPATH/src/github.com/heketi \
 && git clone -b $HEKETI_VERSION https://github.com/heketi/heketi.git \
 && cd heketi \
 && curl -o glide.lock.diff https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Heketi/9.0.0/patch/glide.lock.diff \
 && patch --ignore-whitespace glide.lock < glide.lock.diff \
 && make \
 && cp heketi /usr/bin/ \
 && cp client/cli/go/heketi-cli /usr/bin/ \
 && cd /etc/heketi \
 && wget https://raw.githubusercontent.com/heketi/heketi/v8.0.0/etc/heketi.json \


# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    git \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf $GOPATH/src/github.com/heketi/

WORKDIR /etc/heketi/
VOLUME /etc/heketi/
VOLUME /var/lib/heketi
EXPOSE 8080

CMD ["/usr/bin/heketi","--config=/etc/heketi/heketi.json"]

# End of Dockerfile
