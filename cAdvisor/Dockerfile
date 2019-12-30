# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

######################## Dockerfile for cAdvisor 0.34.0 #################################
#
# This Dockerfile builds a basic installation of cAdvisor.
#
# cAdvisor (Container Advisor) provides container users an understanding of the resource usage
# and performance characteristics of their running containers. It is a running daemon that collects,
# aggregates, processes, and exports information about running containers.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start cAdvisor server create a container from the image created from Dockerfile and
# link 8080 to the port.
# docker run --name <container_name> -p <port_number>:8080 -d <image_name>
#
# Access cAdvisor web user interface from browser
# http://<hostname>:<port_number>
#
##########################################################################################

# Base image
FROM s390x/ubuntu:16.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG CADVISIOR_VER=0.34.0

ENV SOURCE_DIR=/tmp/source
ENV PATH=/usr/lib/go-1.10/bin:$PATH
WORKDIR $SOURCE_DIR

# Set Environmental Variables
ENV GOPATH=$SOURCE_DIR
ENV PATH=$PATH:$GOPATH/bin

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
        golang-1.10 \
        libseccomp-dev \
        curl \
# Install godep tool
 && go get github.com/tools/godep \

# Create directory and Change the work directory
 && mkdir -p $GOPATH/src/github.com/google && cd $GOPATH/src/github.com/google \

# Checkout the code from repository
 && git clone https://github.com/google/cadvisor.git -b v$CADVISIOR_VER \
 && cd cadvisor \

# Change the work directory
 && cd $GOPATH/src/github.com/google/cadvisor \

# Edit `$GOPATH/src/github.com/google/cadvisor/Godeps/_workspace/src/github.com/klauspost/crc32/crc32.go` to add the following code to end of the file
 && echo " func updateCastagnoli(crc uint32, p []byte) uint32 { \n // only use slicing-by-8 when input is >= 16 Bytes \n if len(p) >= 16 { \n return updateSlicingBy8(crc, castagnoliTable8, p) \n }  \n return update(crc, castagnoliTable, p) \n } \n "  >> vendor/github.com/klauspost/crc32/crc32.go \
 && echo "func updateIEEE(crc uint32, p []byte) uint32 { \n // only use slicing-by-8 when input is >= 16 Bytes \n  if len(p) >= 16 { \n  iEEETable8Once.Do(func() { \n iEEETable8 = makeTable8(IEEE) \n }) \n return updateSlicingBy8(crc, iEEETable8, p) \n  } \n  return update(crc, IEEETable, p) \n  } \n " >> vendor/github.com/klauspost/crc32/crc32.go \

# Build cadvisor
 && cd $GOPATH/src/github.com/google/cadvisor \
 && godep go build . \
 && cp $GOPATH/src/github.com/google/cadvisor/cadvisor /usr/bin \
 && cd && rm -rf $SOURCE_DIR \
 && apt-get remove -y git && apt-get autoremove -y && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Multistage build
FROM s390x/ubuntu:16.04

WORKDIR /root
COPY --from=builder /usr/bin/cadvisor /usr/bin/cadvisor
# Port for cAdvisor
EXPOSE 8080

# Command to execute
CMD ["/usr/bin/cadvisor"]

# End of Dockerfile
