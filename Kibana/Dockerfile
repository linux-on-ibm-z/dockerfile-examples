# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################### Dockerfile for Kibana version 6.5.0 ##########################################
#
# This Dockerfile builds a basic installation of Kibana.
#
# Kibana is an open source data visualization plugin for Elasticsearch.
# It provides visualization capabilities on top of the content indexed on an Elasticsearch cluster.
# Users can create bar, line and scatter plots, or pie charts and maps on top of large volumes of data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Kibana container using the below command.
# docker run --name <container_name> -p 5601:5601 -d <image_name>
#
# Start Kibana using sample kibana.yml file using below command.
# docker run --name <container_name> -v <path_on_host>/kibana.yml:/etc/kibana/kibana.yml -p 5601:5601 -d <image_name>
#
# To see the Kibana UI, go to http://<hostname>:<port_number>/ on web browser.
#
##############################################################################################################

FROM s390x/ubuntu:16.04

ARG KIBANA_VER=6.5.0

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Set Environment Variable
ENV PATH=/usr/share/kibana/bin:$PATH

# Install the dependencies and NodeJS
RUN apt-get update && apt-get install -y \
    wget \
    tar \
 && wget https://nodejs.org/dist/v8.11.4/node-v8.11.4-linux-s390x.tar.gz \
 && tar xvf node-v8.11.4-linux-s390x.tar.gz \

# Download and setup Kibana
 && cd /root/ && wget https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VER}-linux-x86_64.tar.gz \
 && tar xvf kibana-${KIBANA_VER}-linux-x86_64.tar.gz \
 && mv /root/kibana-${KIBANA_VER}-linux-x86_64 kibana-${KIBANA_VER} \
 && cd /root/kibana-${KIBANA_VER} \
 && mv node node_old \
 && ln -s /root/node-v8.11.4-linux-s390x node \
 && mkdir /etc/kibana \
 && cp config/kibana.yml /etc/kibana \
 && mv /root/kibana-${KIBANA_VER}/ /usr/share/kibana \

# Cleanup Cache data, unused packages and source files
 && apt-get remove -y \
    unzip \
    wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/kibana-${KIBANA_VER}-linux-x86_64.tar.gz /root/node-v8.11.4-linux-s390x.tar.gz \
 && rm -rf /var/lib/apt/lists/*


# Expose 5601 port used by Kibana
EXPOSE 5601 

# Start Kibana service
CMD ["kibana","-H","0.0.0.0"]
