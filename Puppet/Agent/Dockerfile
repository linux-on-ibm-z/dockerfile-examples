# © Copyright IBM Corporation 2017, 2022
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Puppetagent version 7.16.0 #########
#
# This Dockerfile builds a basic installation of Puppet agent.
#
# When set up as an agent/server architecture, a Puppet server controls the configuration information,
# and each managed agent node requests its own configuration catalog from the master.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> --build-arg SERVER=<server_hostname> .
#
# To run a Puppet agent test execute the following command:
# docker run -it --name <container_name> [--add-host <server_hostname>:<server_ip_address>] <image>
# puppet agent -t
#
# Reference:
# https://puppetlabs.com/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Setting the SERVER argument will override the target server.
ARG SERVER=puppet

# Install dependencies
RUN apt-get update && apt-get install -y ruby

# Install Puppet
RUN gem install bundler rake-compiler \
 && gem install puppet -v 7.16.0

# Configure address of Puppet server
RUN mkdir -p "$(puppet config print confdir)" \
 && puppet config set server "$SERVER"

CMD bash
# End of Dockerfile
