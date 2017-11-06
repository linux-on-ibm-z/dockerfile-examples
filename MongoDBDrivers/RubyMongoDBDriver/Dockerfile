############### Dockerfile for Ruby MongoDBDriver 2.4.3 ####################################
# 
# To build Ruby MongoDBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with Ruby MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-Ruby-MongoDB-Driver
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV GEM_HOME=/root/.gem/ruby
ENV PATH=/root/.gem/ruby/bin:$PATH

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
		g++ \
    gcc \
    make \
    ruby \
    ruby-dev \
	
# Install the mongo gem
 && gem install mongo -v 2.4.3 \

# Clean up the unwanted packages 
 && apt-get remove -y \
      g++ \
	    gcc \
      make \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

# End of Dockerfile
