############### Dockerfile for Perl MongoDBDriver 1.8.0 ####################################
# 
# To build Perl MongoDBDriver image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# The MongoDB Driver needs access to a running MongoDB server, either on your local server or a remote system.
# Download MongoDB binaries for here, install them and run MongoDB server.
# 
# To start container with Perl MongoDBDriver run the below command
# docker run -it --name <container_name> <image_name> /bin/bash
#
# Reference :  https://github.com/linux-on-ibm-z/docs/wiki/Building-Perl-MongoDB-Driver
#############################################################################################


# Base Image
FROM  s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Install dependencies
RUN apt-get update  \
 && apt-get install -y \
      gcc \
      libtest-yaml-perl \
      libyaml-perl \
      make \
      perl-modules-5.22 \
      tar \
      zip \
	
# Build - Install latest CPAN (version 2.16)
 && perl -MCPAN -le 'print "CPAN Version -> $CPAN::VERSION"'  \
 && cpan -fi Bundle::CPAN \
 && perl -MCPAN -le 'print "CPAN Version -> $CPAN::VERSION"' \
 && cpan Config::AutoConf \
 && cpan -fi Path::Tiny \
 
# Build - Perl MongoDB Driver 
 && cpan -fi BSON::Decimal128 BSON::Types \
 && cpan MongoDB \

# Clean up the unwanted packages 
 && apt-get remove -y \
	    gcc \
        make \
        zip \
		
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* 

# End of Dockerfile
