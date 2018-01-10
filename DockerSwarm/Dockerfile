################ Dockerfile for Docker Swarm version 1.2.8 ####################
#
# This Dockerfile builds a basic installation of Docker Swarm.
#
# Docker Swarm is native clustering for Docker. It turns a pool of Docker hosts
# into a single, virtual Docker host.Since Docker Swarm serves the standard Docker API,any tool
# that already communicates with a Docker daemon can use Swarm to transparently scale to multiple hosts
#
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To see help options, run following command:
# docker run -it --name <container-name> <image_name>
#
# To Start the Docker Swarm manager, create and start a container from above image as follows:
# docker run --name <container-name> -it -v /<path_on_host_container_ips_of_slave>:/<path_on_container_ips_of_slave> -p <port>:2375 <image_name> manage --host=0.0.0.0:2375  file://<path_on_container_ips_of_slave>
#
# For ex. docker run --name <container-name> -it -v /mycluster:/mycluster -p <port>:2375 <image_name> manage --host=0.0.0.0:2375 file://mycluster
#
# ########################### Sample mycluster ######################################
#
#  <ip_of_slave_node1>:<port>
#  <ip_of_slave_node2>:<port>
#
##################################################################################


# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set GOPATH environment varibale

ENV GOPATH /go:/go/src/github.com/docker/swarm/Godeps/_workspace/
ENV PATH $GOPATH/bin:/usr/lib/go-1.9/bin:$PATH:$HOME/go/bin
ENV SWARM_HOST :2375


# Install dependencies
RUN apt-get -y update && apt-get install -y \
    git wget tar gcc golang-1.9 \

# Get the dependency tools
&& go get github.com/tools/godep \

# Build Docker Swarm
 && mkdir -p /go/src/github.com/docker \
 && cd / && git clone -b v1.2.8 https://github.com/docker/swarm.git /go/src/github.com/docker/swarm \
 && go install github.com/docker/swarm/ \
 
 
# Tidy up (Clear cache data)
 && apt-get remove -y \
        git \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /go/src/github.com/docker/swarm \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 2375

VOLUME $HOME/.swarm

ENTRYPOINT ["swarm"]
CMD ["--help"]

# End of Dockerfile
