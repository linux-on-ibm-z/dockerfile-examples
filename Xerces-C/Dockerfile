################### Dockerfile for Xerces-C version 3.2.2 #####################
#
# Xerces is Apache's collection of software libraries for parsing, validating, serializing and manipulating XML.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US.UTF-8'
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Install the required package
RUN apt-get update && apt-get install -y \
    automake \
    g++ \
    git-core \
    libtool \
    make \
    locales \
	tar \

# Download and build Xerces-C
 && locale-gen en_US en_US.UTF-8 \
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=$LANG \
 && update-locale LANG=$LANGUAGE \
 && git clone git://github.com/apache/xerces-c.git \
 && cd xerces-c && git checkout Xerces-C_3_2_2 \
 && ./reconf && ./configure \
 && make && make install \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    automake \
    g++ \
    git-core \
    libtool \
    make \
    locales \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
