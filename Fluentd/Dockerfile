########## Dockerfile for Fluentd version 0.12.40 ###############################
#
# This Dockerfile builds a basic installation of Fluentd.
#
# Fluentd is an open source data collector for unified logging layer.
# Fluentd allows you to unify data collection and consumption for a better use and understanding of data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start Fluentd process using below command 
# docker run <container_name> -it -v /<host>:/<contaimer> <image-name> fluentd <argument>
# e.g. docker run --name fluentd -it -v /conf:/conf fluentd_img fluentd -c conf/fluent.conf
#
# Official website: https://www.fluentd.org/
#
##############################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV GEM_HOME=/root/.gem/ruby
ENV PATH=/root/.gem/ruby/bin:$PATH
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
  && apt-get install  -y \
         gcc \
         make \
         ruby \
         ruby-dev \
		 
# Install Fluentd
  && gem install fluentd -v 0.12.40 \
  && gem list fluentd \
 
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
         gcc \
         make \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Setup/Install a config directory
  && fluentd -s conf \
  && cp -a ./* /etc/fluent/

VOLUME /conf

EXPOSE 24224 

# Start Fluentd process
CMD fluentd 

# End of Dockerfile
