############################### Dockerfile for GlusterFS version 3.12.3 ##################################
#
# This Dockerfile builds a basic installation of GlusterFS.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start GlusterFS container using the below command
# docker run --name <container_name> --privileged=true -d <image_name>
#
##############################################################################################################

# Base Image
FROM  s390x/ubuntu:16.04

# The Author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set Environment Variables

ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" SOURCE_DIR="/tmp/"

WORKDIR $SOURCE_DIR

# Install Dependencies
RUN apt-get update && apt-get install -y  make \
    automake \
	autoconf \
	libtool \
	flex \
	bison \
	pkg-config \
	libssl-dev \
	libxml2-dev \
	python-dev \
	libaio-dev \
	libibverbs-dev \
	librdmacm-dev \
	libreadline-dev \
	liblvm2-dev \
	libglib2.0-dev \
	liburcu-dev \
	libcmocka-dev \
	libsqlite3-dev \
	libacl1-dev \
	wget \
	tar \
	dbench \
	git \
	xfsprogs \
	attr \
	nfs-common \
	yajl-tools \
	sqlite3 \
	libxml2-utils \
	thin-provisioning-tools \
	bc \

# Build GlusterFS from source
 && git clone https://github.com/gluster/glusterfs \
 && cd glusterfs \
 && git checkout v3.12.3 \
 && ./autogen.sh \
 && ./configure --enable-gnfs \
 && make \
 && make install \
 && ldconfig \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
   make \
   automake \
   autoconf \
   wget \
   git \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/glusterfs \

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

# Start the Gluster daemon
CMD ["glusterd"]

# End of Dockerfile
