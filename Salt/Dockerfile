# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################### Dockerfile for Salt version 2019.2.2 ##################################
#
# This Dockerfile builds a basic installation of Salt.
#
# SaltStack makes software for complex systems management at scale. 
# SaltStack is the company that created and maintains the Salt Open project and develops and sells SaltStack Enterprise software, services and support.
# Salt is a new approach to infrastructure management built on a dynamic communication bus. 
# Salt can be used for data-driven orchestration, remote execution for any infrastructure, configuration management for any app stack, and much more.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
#
# To start container from image & start an application in production mode
# docker run -v <host_path>:/etc/salt -d <image>
# 
# The official website
# https://saltstack.com/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

ARG SALT_VER=v2019.2.2

# Install dependencies
RUN apt-get update && apt-get install -y \
        g++ \		
        gcc \
		git \
		libffi-dev \
        libsasl2-dev \
		libssl-dev \
        libxml2-dev \
		libxslt1-dev \
		libzmq3-dev \
		make \
        man \
		python3-dev \
		python3-pip \
		tar \
		wget \
	&&  pip3 install --upgrade pip \
# Install required packages using pip3
	&&	pip install \
			pyzmq \
			PyYAML \
			pycrypto \
			msgpack-python \
			jinja2 \
			psutil \
			futures \
			tornado \
# Clone the repository and install SaltStack
&& 	git clone git://github.com/saltstack/salt \
&& 	cd salt \
&& 	git checkout $SALT_VER \
&& 	pip install -e . \
# Configure SaltStack to run self-contained version
&& 	cd $SOURCE_DIR \
&&	mkdir -p etc/salt/pki/master \
&&	mkdir -p etc/salt/pki/minion \
&& 	cp ./salt/conf/master ./salt/conf/minion etc/salt/ \
&& 	cd etc/salt/ \
# Edit config file master
&&	sed -i 's/#user: root/user: root/g' master \
&& 	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' master \
# Edit config file minion
&&	sed -i 's/#master: salt/master: localhost/g' minion \
&&	sed -i 's/#user: root/user: root/g' minion \
&&	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' minion \
# Clean up cache data and remove dependencies which are not required
&&	apt-get remove -y \
			gcc \
			git \
			g++ \
			make \
			wget \
&& apt autoremove -y && apt-get clean \
&& rm -rf salt/ && rm -rf /var/lib/apt/lists/*

VOLUME /etc/salt

CMD salt-master -c ./etc/salt & salt-minion -c ./etc/salt

# End of Dockerfile

