################## Dockerfile for Rails version 5.1.4 ###################################
#
# Rails is a web application development framework written in the Ruby language.
#  
# To build Rails image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run -it <image_name> /bin/bash
#
# Below is the command to use Rails:
# docker run --rm --name <container_name> -it <image_name> rails <argument>
#
# Below is an example to display the installed Rails version :
# docker run --rm --name <container_name> -it <image_name> rails -v
#
#########################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Install dependencies & rails
RUN apt-get update && apt-get install -y \
    gcc \
    make \
    patch \
    ruby \
    ruby-dev \
    zlib1g-dev \
 && gem install rails -v 5.1.4 \

# Tidy up (Clear cache data)
 && apt-get remove -y \
    gcc \
    make \
    patch \
    zlib1g-dev \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port for Rails
EXPOSE 3000

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
