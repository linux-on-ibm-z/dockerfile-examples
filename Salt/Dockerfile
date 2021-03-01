# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################### Dockerfile for Salt version v3001 ##################################
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
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
##################################################################################

# Base Image
FROM ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

ARG SALT_VER=v3001

# Install dependencies
RUN apt-get update && apt-get install -y \
	wget \
	curl \
	python3 \
	git \
	python3-pip \
	libffi-dev \
	libssl-dev \
	&& pip3 install -U pip \
# Install required packages using pip3
	&&	pip3 install \
			pyzmq \
			PyYAML \
			pycryptodome \
			msgpack-python \
			jinja2 \
			psutil \
			futures \
			tornado \
# Clone the repository and install SaltStack
&& 	git clone git://github.com/saltstack/salt \
&& 	cd salt \
&& 	git checkout $SALT_VER \
&& 	pip3 install . \
# Configure SaltStack to run self-contained version
&& 	cd $SOURCE_DIR \
&&	mkdir -p etc/salt/pki/master \
&&	mkdir -p etc/salt/pki/minion \
&& 	cp ./salt/conf/master ./salt/conf/minion etc/salt/ \
&& 	cd etc/salt/ \
# Edit config file master
&&	sed -i 's/#user: root/user: root/g' master \
&& 	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' master \
&&      sed -i 's,#pki_dir: /,'"pki_dir: $SOURCE_DIR/etc/salt/pki/master"',' master \
# Edit config file minion
&&	sed -i 's/#master: salt/master: localhost/g' minion \
&&	sed -i 's/#user: root/user: root/g' minion \
&&	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' minion \
&&      sed -i 's,#pki_dir: /,'"pki_dir: $SOURCE_DIR/etc/salt/pki/minion"',' minion \
&&      sed -i 's,#id:,'"id: saltdev"',' minion \
# Clean up cache data and remove dependencies which are not required
&&	apt-get remove -y \
			wget \
			curl \
			git \
&& apt autoremove -y && apt-get clean \
&& rm -rf salt/ && rm -rf /var/lib/apt/lists/*

VOLUME /etc/salt

CMD salt-master -c ./etc/salt & salt-minion -c ./etc/salt

# End of Dockerfile
