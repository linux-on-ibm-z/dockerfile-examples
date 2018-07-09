# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Salt version 2018.3.2 #########
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
# To start container from image & start an application in production mode
# docker run -v <host_path>:/etc/salt -v <host_dir>:/data -d <image>
# 
# The official website
# https://saltstack.com/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
		bzip2 \
		gcc \
		git \
		g++ \
		libffi-dev \
		libssl-dev \ 
		libtool \
		libxslt1-dev \
		make \
		openssl \
		python \
		python-dev \
		python-ldap \
		python-lxml \
		python-setuptools \ 
		tar \
		unzip \
		wget \
	&&	easy_install pip \
	
# Install required packages using pip
	&&	pip install \
			call \
			coverage==3.7.1 \
			coveralls \
			'django<2.0' \
			funcsigs \
			futures \
			httplib2 \
			jinja2 \
			msgpack-python \
			paramiko \ 
			passlib \
			patch \
			psutil \
			pycrypto \
			PyYAML \
			pyzmq \
			six \
			'tornado<5.0' \
		 
# Clone the repository and install SaltStack
&& 	git clone git://github.com/saltstack/salt \
&& 	cd salt \
&& 	git checkout v2018.3.2 \
&& 	pip install -e . \

# Configure SaltStack to run self-contained version
&& 	cd $SOURCE_DIR \
&&	mkdir -p /etc/salt/pki/master \
&&	mkdir -p /etc/salt/pki/minion \
&& 	cp ./salt/conf/master ./salt/conf/minion etc/salt/ \
&& 	cd etc/salt/ \

# Edit config file master
&&	sed -i 's/#user: root/user: root/g' master \
&& 	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' master \
&&	sed -i 's,#pki_dir: /etc/salt/pki/master,'"pki_dir: /etc/salt/pki/master"',' master \

# Edit config file minion
&&	sed -i 's/#master: salt/master: localhost/g' minion \
&&	sed -i 's/#user: root/user: root/g' minion \
&&	sed -i 's,#root_dir: /,'"root_dir: $SOURCE_DIR"',' minion \
&&  sed -i 's,#pki_dir: /etc/salt/pki/minion,'"pki_dir: /etc/salt/pki/minion"',' minion \

# Clean up cache data and remove dependencies which are not required
&&	apt-get remove -y \
			bzip2 \
			gcc \
			git \
			g++ \
			make \
			openssl \ 
			unzip \
			wget \
&& apt autoremove -y && apt-get clean \
&& rm -rf salt/ && rm -rf /var/lib/apt/lists/*

VOLUME /etc/salt

VOLUME /data

CMD  salt-master -c ./etc/salt & salt-minion -c ./etc/salt

# End of Dockerfile
