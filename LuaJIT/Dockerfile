########## Dockerfile for LuaJIT version 2.1 #########
#
# This Dockerfile builds a basic installation of LuaJIT.
#
# LuaJIT is a Just-In-Time (JIT) compiler for the Lua programming language. Lua is a powerful, dynamic and light-weight programming language. 
# It may be embedded or used as a general-purpose, stand-alone language.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply check the resultant image and LuaJIT version, use the command:
# docker run  --name <container_name> -it <image_name> luajit -v
#
# To use LuaJIT image from command line, use following command:
# docker run --name <container_name> -v <Lua_source_file_path_in_host>:<Lua_source_file_path_in_container> -it <image_name> /bin/bash
# For ex. docker run --name luajit_test -v /root/test/luajit:/root -it luajit /bin/bash
#
# Official website: http://luajit.org
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
WORKDIR $SOURCE_DIR

# Install dependencies
RUN  apt-get update  \
  && apt-get -y install gcc \
	 git \
	 make  \
  && cd $SOURCE_DIR \
  && git clone git://github.com/linux-on-ibm-z/LuaJIT.git \
  && cd $SOURCE_DIR/LuaJIT/ \
  && git checkout v2.1 \
  && make \
  && make install \
  && ln -s luajit-2.1.0-beta3 /usr/local/bin/luajit \
  
# Clean up the unwanted packages and clear the source directory 
  && apt-get remove -y \
     gcc \
	 git \
	 make \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/LuaJIT /var/lib/apt/lists/*

CMD ["luajit"]

# End of Dockerfile
