# © Copyright IBM Corporation 2017, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Puppetagent version 6.13.0 #########
#
# This Dockerfile builds a basic installation of Puppet agent.
#
# When set up as an agent/master architecture, a Puppet server controls the configuration information,
# and each managed agent node requests its own configuration catalog from the master.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Puppet agent run the below command:
# docker run -dit --name <container_name> --network host --add-host <server hostname>:<IP address of server> <image>
# then update $confdir/puppet.conf (see Note 1) and run:
# puppet agent --debug -t
#
# Reference:
# https://puppetlabs.com/
#
##################################################################################
#
#	              -: NOTE :-
# 1. Add the following parameters to $confdir/puppet.conf
#  	(assuming hostname of the master machine is master.myhost.com and hostname of the agent machine is agent.myhost.com)
#  	 Use command -> confdir=`puppet agent --configprint confdir` (it will give you value for $confdir )
#
# 	Hostname can be found by running the command 'hostname -f'
#
#    [main]
#          logdir =  $confdir/var/log/puppetlabs
#          basemodulepath = /etc/puppetlabs/puppet/modules
#          server = master.myhost.com
#          pluginsync = false
#     [agent]
#          certname = agent.myhost.com
#          report = true
#          pluginsync = false
#
#  2. Add an entry in /etc/hosts file with ipaddress and hostname of master node
#		<master ipaddress> <master hostname>
#
##################################################################################


# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Install dependencies
RUN	apt-get update && apt-get install -y \
	g++ \
	libssl1.0-dev \
	make \
	openssl1.0 \
	ruby \
	ruby-dev \
	tar \
	wget \

# Install bundler
	&&	cd $SOURCE_DIR \
	&&	/usr/bin/gem install bundler rake-compiler \

# Install Puppet
	&&	/usr/bin/gem install facter -v 2.5.7 \
	&&	/usr/bin/gem install puppet -v 6.13.0 \

# Locate the $confdir by command
	&&	chmod 755 /usr/local/lib \
	&&	export confdir=`puppet agent --configprint confdir` \
	&&	mkdir -p $confdir \

# Create necessary directories and files in $confdir
	&&	cd $confdir \
	&&	mkdir -p $confdir/opt/puppetlabs/puppet \
	&&	mkdir -p $confdir/var/log \
	&&	touch puppet.conf \

# Add sample puppet.conf (Make changes according to your machine configuration)
	&& 	agenthost=$(hostname -f) \
	&& 	echo "[main]" >> puppet.conf \
	&&	echo "        logdir = $confdir/var/log" >> puppet.conf \
	&&	echo "        basemodulepath = $confdir/modules" >> puppet.conf \
	&&	echo "        server = masterhost" >> puppet.conf \
	&&	echo "        pluginsync = false" >> puppet.conf \
	&&	echo "" >> puppet.conf \
	&&	echo "[agent]" >> puppet.conf \
	&&	echo "        certname = agenthost" >> puppet.conf \
	&&	echo "        report = true" >> puppet.conf \
	&&	echo "        autosign = true" >> puppet.conf \

# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		make \
		unzip \
		wget \
	&& 	apt autoremove -y \
	&&  apt-get autoremove -y \
	&&  apt-get clean \
	&&  rm -rf /var/lib/apt/lists/*

CMD bash

# End of Dockerfile
