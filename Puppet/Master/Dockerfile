# © Copyright IBM Corporation 2017, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for Puppet-master version 5.5.2 ####################
#
# This Dockerfile builds a basic installation of Puppet-master.
#
# When set up as an agent/master architecture, a Puppet master server controls the configuration information,
# and each managed agent node requests its own configuration catalog from the master.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Puppet master run the below command:
# docker run --name <container_name> -d <image>
#
# To start Puppet with custom configuration , use:
# docker run --name <container_name> -d <image>
#
# Reference:
# https://puppetlabs.com/
#
################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Install dependencies
RUN     apt-get update && apt-get install -y \
        cron \
        g++ \
        git \
        libc6-dev \
        libreadline7 \
        libsqlite3-dev \
        libssl1.0-dev \
        libyaml-dev \
        locales \
        make \
        openssl \
        wget \
        zlibc \
        zlib1g-dev \
        zlib1g \
        libxml2-dev \
        libgdbm-dev \

# Build Ruby
        &&      cd $SOURCE_DIR \
        &&      wget http://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz \
        &&      tar -xvf ruby-2.4.1.tar.gz \
        &&      cd ruby-2.4.1 \
        &&      ./configure \
        &&      make \
        &&      make install \

# Install bundler
        &&      cd $SOURCE_DIR \
        &&      /usr/local/bin/gem install bundler rake-compiler \

# Install Puppet
        &&      /usr/local/bin/gem install puppet -v 5.5.2 \

# Locate the $confdir by command
        &&      chmod 755 /usr/local/lib \
        &&      confdir=`puppet master --configprint confdir` \
        &&      mkdir -p $confdir \

# Create necessary directories and files in $confdir
        &&      mkdir $confdir/modules \
        &&      mkdir $confdir/manifests \
        &&      cd $confdir \
        &&      touch puppet.conf \
        &&      wget https://raw.githubusercontent.com/puppetlabs/puppet/5.5.2/conf/auth.conf \
        &&      mkdir -p $confdir/opt/puppetlabs/puppet \
        &&      mkdir -p $confdir/var/log/puppetlabs \

# Create "puppet" user and group
        &&      useradd -d /home/puppet -m -s /bin/bash puppet \
        &&      /usr/local/bin/puppet resource group puppet ensure=present \

# Add sample puppet.conf
        &&      echo "[main]" >> puppet.conf \
        &&      echo "        logdir = $confdir/var/log/puppetlabs" >> puppet.conf \
        &&      echo "        basemodulepath = $confdir/modules" >> puppet.conf \
        &&      echo "        server = hostname" >> puppet.conf \
        &&      echo "        user  = puppet" >> puppet.conf \
        &&      echo "        group = puppet" >> puppet.conf \
        &&      echo "        pluginsync = false" >> puppet.conf \
        &&      echo "" >> puppet.conf \
        &&      echo "[master]" >> puppet.conf \
        &&      echo "        certname = hostname" >> puppet.conf \
        &&      echo "            autosign = true" >> puppet.conf \

# Clean up cache data and remove dependencies which are not required
        &&      apt-get -y remove \
                git \
                make \
                unzip \
                wget \
        &&  apt autoremove -y \
        &&  apt-get autoremove -y \
        &&  apt-get clean \
        &&  rm -rf /var/lib/apt/lists/*

CMD sed -i "s/hostname/$HOSTNAME/" /etc/puppetlabs/puppet/puppet.conf && puppet master --verbose --no-daemonize

# End of Dockerfile
