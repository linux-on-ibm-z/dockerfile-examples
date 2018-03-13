####################### Dockerfile for Python Ceilometer client version 2.9.0 #############################################
#
# This is a client library for Ceilometer built on the Ceilometer API.
# It provides a Python API (the ceilometerclient module) and a command-line tool (ceilometer).
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# docker run --name <container_name> -d <image_name>
#
############################################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    findutils \
    gcc \
    python-setuptools \
    python-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
 && easy_install pip \
 && pip install pbr virtualenv cryptography \
 
# Clone and install Python Ceilometerclient
 && git clone git://github.com/openstack/python-ceilometerclient.git \
 && cd python-ceilometerclient \
 && git checkout 2.9.0 \
 && pip install -r requirements.txt \
 && python setup.py install \
 && rm -rf $SOURCE_DIR \
 
# Tidy up (Clear cache data)
 && apt-get remove -y \
    python-dev \
    python-setuptools \
 && apt-get autoremove -y && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["ceilometer" , "--version"]
