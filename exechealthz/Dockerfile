############################# Dockerfile for exechealthz #####################################
#
# This Dockerfile builds a basic installation of exechealthz.
# The exec healthz server is a sidecar container meant to serve as a liveness-exec-over-http bridge. 
# It isolates pods from the idiosyncrasies of container runtime exec implementations.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start exechealthz run the below command:
# docker run --rm --name <container_name> -p 8080:8080 exechealthz ./exechealthz -cmd <cmd>
# 
# http://<hostname>:<port_number>/healthz
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#####################################################################################################


# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)

# Install dependencies
RUN apt-get update && apt-get install -y \
        wget \
        gcc \
        tar \
        git \
        make \
        docker \
        golang \
        curl \
# Get the source
&& mkdir /root/exechealthz \
&& cd /root/exechealthz && git clone https://github.com/linux-on-ibm-z/contrib.git \
&& cd contrib && git checkout 0.7.0-s390x \
&& mkdir /usr/share/exechealthz && cp -Rf exec-healthz /usr/share/exechealthz/ \

# Clean up the unwanted packages and clear the source directory
&& apt-get remove -y \
    curl \
    git \
    wget \
&& apt-get autoremove -y && apt-get clean \
&& rm -rf /root/exechealth /var/lib/apt/lists/*

WORKDIR /usr/share/exechealthz/exec-healthz/

RUN make ARCH=s390x server 

EXPOSE 8080
