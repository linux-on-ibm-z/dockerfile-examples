##################### Dockerfile for Heketi 5.0.1 ########################
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
ENV PATH=$PATH:/usr/lib/go-1.9/bin:$GOPATH/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git  \
    golang-1.9 \
    curl \

# Clone heketi source
 && mkdir -p /etc/heketi /var/lib/heketi $GOPATH/bin /etc/heketi \
 && git clone https://github.com/heketi/heketi.git $GOPATH/src/github.com/heketi/heketi \
 && cd $GOPATH/src/github.com/heketi/heketi \
 && git checkout v5.0.1 \
 && echo $GOPATH/bin \
 && go version \
 && curl https://glide.sh/get | sh \

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
