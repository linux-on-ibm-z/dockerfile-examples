########## Dockerfile for Puppet-agent version 5.3.4 #########
#
# This Dockerfile builds a basic installation of Puppet-agent.
#
# When set up as an agent/master architecture, a Puppet master server controls the configuration information, 
# and each managed agent node requests its own configuration catalog from the master.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Puppet-agent run the below command:
# docker run --name <container_name> --add-host <container id of master>:<IP address of master> -e masterhost="<container id of master>" -d <image>  
# 
# Reference:
# https://puppetlabs.com/
#
##################################################################################
#
#	              -: NOTE :-
# 1. Add the following parameters to $confdir/puppet.conf 
#  	(assuming hostname of the master machine is master.myhost.com and hostname of the agent machine is agent.myhost.com)
#  	 Use command -> confdir='puppet master --configprint confdir' (it will give you value for $confdir )
#
# 	Hostname can be found by running the command 'hostname -f'
#
#    [main]
#          logdir =  $confdir/var/log/puppetlabs
#          basemodulepath = /etc/puppetlabs/puppet/modules
#          server = master.myhost.com
#          user  = puppet
#          group = puppet
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
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Install dependencies
RUN	apt-get update && apt-get install -y \
	cron \
	g++ \
	git \
	libc6-dev \
	libreadline6 \
	libreadline6-dev \
	libsqlite3-dev \
	libssl-dev \
	libyaml-dev \
	locales \
	make \
	openssl \
	ruby \
	ruby-dev \
	tar \
	unzip \
	wget \
	
# Install bundler
	&&	cd $SOURCE_DIR \
	&&	/usr/bin/gem install bundler rake-compiler \
	
# Install Puppet
	&&	/usr/bin/gem install puppet -v 5.3.4 \
	
# Locate the $confdir by command
	&&	chmod 755 /usr/local/lib \
	&&	confdir=`puppet master --configprint confdir` \
	&&	mkdir -p $confdir \
	
# Create necessary directories and files in $confdir
	&&	cd $confdir \
	&&	mkdir -p $confdir/opt/puppetlabs/puppet \
	&&	mkdir -p $confdir/var/log/puppetlabs \
	&&	touch puppet.conf \
	
# Add sample puppet.conf (Make changes according to your machine configuration)
	&& 	agenthost=$(hostname -f) \
	&& 	echo "[main]" >> puppet.conf \ 
	&&	echo "        logdir = $confdir/var/log/puppetlabs" >> puppet.conf \
	&&	echo "        basemodulepath = $confdir/modules" >> puppet.conf \
	&&	echo "        server = masterhost" >> puppet.conf \
	&&	echo "        user  = puppet" >> puppet.conf \
	&&	echo "        group = puppet" >> puppet.conf \
	&&	echo "        pluginsync = false" >> puppet.conf \
	&&	echo "" >> puppet.conf \
	&&	echo "[agent]" >> puppet.conf \
	&&	echo "        certname = agenthost" >> puppet.conf \
	&&	echo "        report = true" >> puppet.conf \
	&&	echo "		  autosign = true" >> puppet.conf \

# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		git \
		make \ 
		unzip \
		wget \
	&& 	apt autoremove -y \
	&&  apt-get autoremove -y \
	&&  apt-get clean \
	&&  rm -rf /var/lib/apt/lists/*
	
CMD sed -i "s/masterhost/$masterhost/" /etc/puppetlabs/puppet/puppet.conf && sed -i "s/agenthost/$HOSTNAME/" /etc/puppetlabs/puppet/puppet.conf && puppet agent --test

# End of Dockerfile
