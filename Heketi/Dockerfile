# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################### Dockerfile for Heketi 7.0.0########################
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
MAINTAINER LoZ Open Source Ecosystem

ENV GOPATH=/build
ENV PATH=$PATH:/usr/lib/go-1.10/bin:$GOPATH/bin:$GOPATH/src/github.com/heketi/heketi/linux-s390x

# Install dependencies
RUN apt-get update && apt-get install -y \
    git  \
    golang-1.10 \
    curl \
    python \
    mercurial \
	wget \
	tar \

# Clone heketi source
 && mkdir -p /etc/heketi /var/lib/heketi $GOPATH/bin /etc/heketi \
 && git clone https://github.com/heketi/heketi.git $GOPATH/src/github.com/heketi/heketi \
 && cd $GOPATH/src/github.com/heketi/heketi \
 && git checkout v7.0.0 \
 && echo $GOPATH/bin \
 && go version \
 && wget https://github.com/Masterminds/glide/releases/download/v0.13.1/glide-v0.13.1-linux-s390x.tar.gz \
 &&	tar -xvf glide-v0.13.1-linux-s390x.tar.gz \
 && glide --version \
 


# Build Heketi
 && make \
 && cp heketi /usr/bin/heketi \
 && cp client/cli/go/heketi-cli /usr/bin/heketi-cli \
 && cp etc/heketi.json /etc/heketi/heketi.json \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    git \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf $GOPATH/src/github.com/heketi/heketi

WORKDIR /etc/heketi/
VOLUME /etc/heketi/
VOLUME /var/lib/heketi
EXPOSE 8080

CMD ["/usr/bin/heketi","--config=/etc/heketi/heketi.json"]

# End of Dockerfile
