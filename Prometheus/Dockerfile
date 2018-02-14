########## Dockerfile for Prometheus 2.1.0 #########
#
# This Dockerfile builds Prometheus
#
#Prometheus is a systems and service monitoring system. It collects metrics
#from configured targets at given intervals, evaluates rule expressions,
#displays the results, and can trigger alerts if some condition is observed to be true
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use the following command to start Prometheus container.
# docker run --name <container name> -p <host_port>:9090 -d <image name>
#
# Start container with custom config file
# docker run --name <container name> -p <host_port>:9090 -v <path_on_host>/prometheus.yaml:/etc/prometheus/prometheus.yml -d <image name>
##########################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV GOPATH=/go PATH=/usr/lib/go-1.9/bin:$PATH:/go/bin:/prometheus

#Install depenedencies
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    gcc \
    git \
    g++ \
    make \
    tar \
    wget \
	golang-1.9 \


# Download and build Prometheus
 && mkdir -p $GOPATH/src/github.com/prometheus \
 && cd $GOPATH/src/github.com/prometheus \
 && git clone https://github.com/prometheus/prometheus.git \
 && cd prometheus \
 && git checkout v2.1.0 \
 && make build \
 && mkdir -p /prometheus && cp -p prometheus promtool /prometheus/ \
 && mkdir -p /etc/prometheus \
 && cp -p documentation/examples/prometheus.yml /etc/prometheus/prometheus.yml \
 && chmod +x /etc/prometheus/prometheus.yml \
 && cp -Rf console_libraries /etc/prometheus/ \
 && cp -Rf consoles /etc/prometheus/ \
 && rm -rf /go/src/github.com \

# Clean up unwanted packages
 && apt-get remove -y \
    cmake \
    curl \
    gcc \
    git \
    g++ \
    make \
    wget \
	golang-1.9 \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

#Export port 9090
EXPOSE 9090
VOLUME [ "/prometheus" ]

CMD prometheus --config.file=/etc/prometheus/prometheus.yml --web.console.libraries=/etc/prometheus/console_libraries --web.console.templates=/etc/prometheus/consoles
