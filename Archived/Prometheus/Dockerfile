# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Prometheus 2.15.2 #########
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
# docker run --name <container name> -p <host_port>:9090 -v <path_on_host>/prometheus.yml:/etc/prometheus/prometheus.yml -d <image name>
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
##########################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

ARG PROMETHEUS_VER=2.15.2

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV PATH=/prometheus:$PATH

#Install depenedencies
RUN apt-get update && apt-get install -y \
    tar \
    wget \
# Download Prometheus
 && wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VER}/prometheus-${PROMETHEUS_VER}.linux-s390x.tar.gz \
 && tar -xzf prometheus-${PROMETHEUS_VER}.linux-s390x.tar.gz \
 && mkdir -p /prometheus && mkdir -p /etc/prometheus \
 && cd prometheus-${PROMETHEUS_VER}.linux-s390x/ \
 && cp -p prometheus promtool /prometheus/ \
 && cp -p prometheus.yml /etc/prometheus/prometheus.yml \
 && chmod +x /etc/prometheus/prometheus.yml \
 && cp -Rf console_libraries /etc/prometheus/ \
 && cp -Rf consoles /etc/prometheus/ \
# Clean up unwanted packages
 && cd .. && rm -rf prometheus-${PROMETHEUS_VER}.linux-s390x prometheus-${PROMETHEUS_VER}.linux-s390x.tar.gz \
 && apt autoremove -y \
 && rm -rf /var/lib/apt/lists/*

#Export port
EXPOSE 9090
VOLUME [ "/prometheus" ]
ENTRYPOINT [ "/prometheus/prometheus" ]
CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--web.console.libraries=/etc/prometheus/console_libraries", "--web.console.templates=/etc/prometheus/consoles" ]
#End of dockerfile
