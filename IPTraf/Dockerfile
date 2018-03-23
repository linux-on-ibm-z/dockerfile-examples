########## Dockerfile for IPTraf version 3.0.0 #########
#
# This Dockerfile builds a basic installation of IPTraf.
#
# IPTraf is a console-based network statistics utility for Linux. It gathers a variety of figures such as TCP connection packet and byte counts, 
# interface statistics and activity indicators, TCP/UDP traffic breakdowns, and LAN station packet and byte counts.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Run iptraf inside a container using below command : 
# docker run --name <container_name> -it <image-name> 
# e.g. docker run --name iptraf_test -it iptraf
#
# Official website: http://iptraf.seul.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV PATH=$PATH:/usr/local/bin
WORKDIR $SOURCE_DIR 

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
		gcc \
		libncurses5 \
		libncurses5-dev \
		make \
		tar \
		wget \
		
# Download and build source code of IPTraf		
 && cd $SOURCE_DIR \
 && wget ftp://iptraf.seul.org/pub/iptraf/iptraf-3.0.0.tar.gz \
 && tar zxvf iptraf-3.0.0.tar.gz \
 && cd $SOURCE_DIR/iptraf-3.0.0 \
 && cp /usr/include/netinet/if_tr.h /usr/include/linux/ \
 && ./Setup \
                   					
# Clean up the unwanted packages and clear the source directory 
 && apt-get remove -y \
        gcc \
		make \
		wget \
		 
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf $SOURCE_DIR/iptraf-3.0.0.tar.gz  $SOURCE_DIR/iptraf-3.0.0 /var/lib/apt/lists/* 

# Start of iptraf service
CMD ["iptraf"]

# End of Dockerfile
