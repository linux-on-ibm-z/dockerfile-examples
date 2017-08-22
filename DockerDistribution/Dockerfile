############### Dockerfile for Docker Distribution version v2.6.2 #################
#
# This Dockerfile builds a basic installation of Docker Distribution.
#
# Docker Distribution is the Docker Registry 2.0 implementation for storing and distributing Docker images.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Docker Distribution, create and start a container from above image as follows:
# docker run --name <container_name> -p 5000:5000 -d <image_name>
#
# To start Docker Distribution using sample_config.yml file using below command:
# docker run --name <container_name> -v <path_on_host>/sample_config.yml:/etc/docker/registry/config.yml -p 5000:5000  -d <image_name>
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV GOPATH /go
ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV PATH $PATH:$GOPATH/bin

# Install dependencies 
RUN apt-get update && apt-get install -y \
    git \
    golang \
    make \

# Download and build source code of Docker Distribution
 && git clone https://github.com/docker/distribution.git $GOPATH/src/github.com/docker/distribution \
 && cd $GOPATH/src/github.com/docker/distribution && git checkout v2.6.2 \
 && make PREFIX=$GOPATH clean binaries \
 && mkdir -p /etc/docker/registry \
 && cp $DISTRIBUTION_DIR/cmd/registry/config-dev.yml /etc/docker/registry/config.yml \

# Tidy up (Clear cache data)
 && apt-get remove -y \
    git \
	golang \
	make \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf $DISTRIBUTION_DIR \
 && rm -rf /var/lib/apt/lists/*

VOLUME ["/var/lib/registry"]

EXPOSE 5000

ENTRYPOINT ["registry"]

CMD ["serve", "/etc/docker/registry/config.yml"]
# End of Dockerfile
