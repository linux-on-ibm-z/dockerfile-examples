############### Dockerfile for Python MongoDBDriver 3.6.0 ####################################
# 
# To build Python MongoBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with Python MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-python-MongoDB-Driver
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
      git \
      libssh-dev \
      openssl \
      python \
      python-openssl \
      python-pip \
      python-setuptools \
	
# Download and configure the python Driver 
 && git clone git://github.com/mongodb/mongo-python-driver.git pymongo \
 && cd pymongo \
 && git checkout 3.6.0 \
 && python setup.py install \
 
#clean up the unwanted packages 
 && apt-get remove -y \
	    git \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

# End of Dockerfile
