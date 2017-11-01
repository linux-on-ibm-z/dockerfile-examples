########## Dockerfile for Apache Geode version 1.2.0 #####################
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
# docker run --name <container_name> -v <host_path>:/geode -d <image>  
# 
# Reference:
# http://geode.incubator.apache.org/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x \
	PATH=$PATH:$JAVA_HOME/bin:/geode/geode-assembly/build/install/apache-geode/bin/ \
	LANG="en_US.UTF-8" JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8" \
	_JAVA_OPTIONS=-Xmx2048m JVM_ARGS="-Xms2048m -Xmx2048m"

# Install dependencies
RUN	apt-get update && apt-get -y install \
		git \
		openjdk-8-jdk \		
# Get the source
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/apache/incubator-geode.git \
	&&	cd incubator-geode/ \
	&&	git checkout rel/v1.2.0 \
# Build Apache Geode source 
	&&	sed -i "44iorg.gradle.jvmargs = -Xss1g" 'gradle.properties' \
	&&	./gradlew build installDist -x test \
# Copy default config file
	&&	mv $SOURCE_DIR/incubator-geode /geode \
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		git \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&&	rm -rf $HOME/.gradle \
	&& 	rm -rf $SOURCE_DIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
VOLUME /geode

CMD ["gfsh"]

# End of Dockerfile