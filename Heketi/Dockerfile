# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################### Dockerfile for Heketi 10.2.0 ########################
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
FROM s390x/ubuntu:18.04
# Maintainer
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG HEKETI_VERSION=v10.2.0
COPY heketi-start.sh /heketi-start.sh
COPY heketi.json /heketi.json

# Install dependencies
RUN apt-get update && apt-get install -y wget tar \
    && apt-get -y clean all \
    && wget https://github.com/heketi/heketi/releases/download/$HEKETI_VERSION/heketi-$HEKETI_VERSION.linux.s390x.tar.gz \
    && tar -xvf heketi-$HEKETI_VERSION.linux.s390x.tar.gz \
    && mkdir  /etc/heketi /var/lib/heketi  \
    && cp heketi/heketi /usr/bin/heketi \
    && cp heketi/heketi-cli /usr/bin/heketi-cli \
    && cp heketi-start.sh /usr/bin/heketi-start.sh \
    && cp -r heketi.json /etc/heketi/heketi.json \
    && chmod +x /usr/bin/heketi-start.sh

VOLUME /etc/heketi /var/lib/heketi
EXPOSE 8080
ENTRYPOINT ["/usr/bin/heketi-start.sh"]
# End of Dockerfile
