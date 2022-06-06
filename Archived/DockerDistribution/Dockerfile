# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Docker Distribution version v2.7.1 #################
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
# docker run -d -p 5000:5000 --name <container_name> <image_name>
#
# To start Docker Distribution using sample_config.yml file using below command:
# docker run -d -p 5000:5000 --name <container_name> -v <path_on_host>/sample_config.yml:/etc/docker/registry/config.yml <image_name>
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The Author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG DOCKER_DISTRIBUTION_VER=2.7.1

ENV GOPATH /go
ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV PATH=$PATH:/usr/share:/usr/local/go/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
	git \
	make \
	tar \
	wget \
	ca-certificates \
# Install go
 && cd /root \
 && wget https://storage.googleapis.com/golang/go1.11.4.linux-s390x.tar.gz \
 && chmod ugo+r go1.11.4.linux-s390x.tar.gz \
 && tar -C /usr/local -xzf go1.11.4.linux-s390x.tar.gz \
# Download and build source code of Docker Distribution
 && git clone https://github.com/docker/distribution.git $DISTRIBUTION_DIR \
 && cd $DISTRIBUTION_DIR && git checkout v${DOCKER_DISTRIBUTION_VER} \
 && make clean binaries \
 && mkdir -p /etc/docker/registry \
 && cp -r $DISTRIBUTION_DIR/bin/registry /bin/registry \
# Tidy up (Clear cache data)
 && apt-get remove -y \
	git \
	make \
	wget \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm /root/go1.11.4.linux-s390x.tar.gz \
 && rm -rf $DISTRIBUTION_DIR \
 && rm -rf /var/lib/apt/lists/*

COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]

# End of Dockerfile
