# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for  XMLSec version 1.2.29 ######################
#
# XMLSec is a C library that implements the standards XML Signature and XML Encryption.
#
# To build XMLSec image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use XMLSec:
# docker run --rm --name <container name> -it <image_name> xmlsec1 <argument>
#
# For example, to display help:
# docker run --rm --name <container name> -it <image_name> xmlsec1 --help
#
#############################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV LD_LIBRARY_PATH /usr/local/lib

# Install dependencies
RUN apt-get update && apt-get install -y \    
    git \
	make \
	autoconf \
    libtool \
    libtool-bin \
    libssl-dev \
    libxslt1-dev \
    pkg-config \
# Clone and build XMLSec
 && git clone git://github.com/lsh123/xmlsec.git && cd xmlsec && git checkout xmlsec-1_2_29 \
 && ./autogen.sh && make && make install \
# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    autoconf \
    git \
    make \
 && apt-get clean
 
# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
