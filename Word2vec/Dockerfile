# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for word2vec version 0.1c #########################################
#
# This Dockerfile builds a basic installation of word2vec.
#
# word2vec is a toll which provides an efficient implementation of the continuous bag-of-words and skip-gram architectures for computing
# vector representations of words. These representations can be subsequently used in many natural language processing applications and
# for further research
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# Example to run word2vec on bash shell
# Example: ./word2vec -train data.txt -output vec.txt -debug 2 -size 200 -window 5 -sample 1e-4 -negative 5 -hs 0 -binary 0 -cbow 1
#
# To check word2vec options run below command.
# docker run --rm=true --name <container_name> -it <image_name> word2vec
# 
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#########################################################################################################

# Base image
FROM s390x/ubuntu:20.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)

WORKDIR "/usr/share"

# Set environment variable
ENV PATH=$PATH:/usr/share/word2vec/trunk/

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    make \
    tar \
    unzip \
    wget \
      
# Download source code
 && wget https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/word2vec/source-archive.zip \
 && unzip source-archive.zip \

# Build word2vec
 && cd word2vec/trunk && \
    make CFLAGS="-lm -pthread -O3 -Wall -funroll-loops" \

 # Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    gcc \
	git \
	make \
    unzip \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/share/source-archive.zip


# Note: Execute demo scripts packaged in source code to get better idea on word2vec (e.g. demo-word.sh, demo-phrases.sh).	
	
# End of Dockerfile
