########## Dockerfile for Ruby version 2.5.0 #########
#
# Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.
# It has an elegant syntax that is natural to read and easy to write.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use Ruby:
# docker run --name <container_name> --rm=true <ruby image> ruby <argument>
#
# For example to execute a test file using Ruby:
# docker run --name <container_name> -v /home/test/test.rb:/home/test.rb --rm=true <ruby image> ruby /home/test.rb
#
# ########################### Sample test.rb ######################################
#
# puts RUBY_VERSION
#
# #################################################################################
#
#####################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/root
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    make \
    wget \
    tar \
    bzip2 \
    subversion \
    bison \
    flex \
    openssl \

# Install Ruby
 && wget http://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.0.tar.gz \
 && tar -xvf ruby-2.5.0.tar.gz \
 && cd ruby-2.5.0 \
 && ./configure \
 && make \
 && make install \
 
# Tidy up (Clear cache data)
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    gcc \
    make \
    bzip2 \
    bison \
    flex \
    openssl \
    subversion \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/bin:$PATH
CMD ["ruby","-v"]

# End of Dockerfile
