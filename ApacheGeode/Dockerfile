# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apache Geode version 1.13.3 #####################
#
# This Dockerfile builds a basic installation of Apache Geode.
#
# Apache Geode is a data management platform that provides real-time, consistent access to data-intensive
# applications throughout widely distributed cloud architectures. Geode pools memory, CPU, network resources, and
# optionally local disk across multiple processes to manage application objects and behavior. It uses dynamic replication
# and data partitioning techniques to implement high availability, improved performance, scalability, and fault tolerance.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Geode run the below command:
# docker run -it --name <container_name> -p 10334:10334 -p 7575:7575 -p 1099:1099 <image>
#
# Reference:
# http://geode.apache.org/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG GEODE_VER=1.13.3
ARG file=apache-geode-$GEODE_VER.tgz

ENV WORKDIR=/root
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$JAVA_HOME/bin:$WORKDIR/apache-geode-$GEODE_VER/bin:$PATH

WORKDIR /root
# Installing dependencies
RUN apt-get update && apt-get install -y \
    tar \
    wget \
    openjdk-8-jdk 
 # Download and extract apache geode
RUN  for url in \
			"https://www.apache.org/dyn/closer.cgi?action=download&filename=geode/$GEODE_VER/$file" \
			"https://downloads.apache.org/geode/$GEODE_VER/$file" \
			"https://archive.apache.org/dist/geode/$GEODE_VER/$file" \
		; do \
			if wget -O "$file" "$url"; then \
				break; \
			fi; \
		done; 
 
RUN tar -xvzf apache-geode-$GEODE_VER.tgz \
# Clean up cache data and remove dependencies which are not required
 && apt-get remove -y \
                 wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /root/apache-geode-$GEODE_VER.tgz \
# smoke test to ensure the shell can still run properly after removing temporary deps
 && gfsh version
# Default ports:
# RMI/JMX 1099
# REST 8080
# PULE 7070
# LOCATOR 10334
# CACHESERVER 40404
EXPOSE  8080 10334 40404 1099 7070
VOLUME ["/data"]
CMD ["gfsh"]

# End of Dockerfile
