############################### Dockerfile for Kibana version 5.6.1 ##########################################
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

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Set Environment Variable
ENV PATH=/usr/share/node-v6.9.1/bin:/usr/share/kibana/bin:$PATH

# Install the dependencies and NodeJS
RUN apt-get update && apt-get install -y \
    apache2 \
    g++ \
    gcc \
    git \
    make \
    nodejs \
    openjdk-8-jdk \
    python \
    unzip \
    wget \
    tar \
 && wget https://nodejs.org/dist/v6.9.1/node-v6.9.1-linux-s390x.tar.gz \
 && tar xvzf node-v6.9.1-linux-s390x.tar.gz \
 && mv /root/node-v6.9.1-linux-s390x/ /usr/share/node-v6.9.1 \

# Download and setup Kibana
 && cd /root/ && wget https://artifacts.elastic.co/downloads/kibana/kibana-5.6.1-linux-x86_64.tar.gz \
 && tar xvf kibana-5.6.1-linux-x86_64.tar.gz \
 && mv /root/kibana-5.6.1-linux-x86_64 kibana-5.6.1 \
 && cd /root/kibana-5.6.1 \
 && mv node node_old \
 &&     ln -s /usr/share/node-v6.9.1/bin/node node \
 && mkdir /etc/kibana \
 && cp config/kibana.yml /etc/kibana \
 && mv /root/kibana-5.6.1/ /usr/share/kibana \

# Cleanup Cache data , unused packages and source files
 && apt-get remove -y \
    git \
    make \
    unzip \
    wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/kibana-5.6.1-linux-x86_64.tar.gz /root/node-v6.9.1-linux-s390x.tar.gz \
 && rm -rf /var/lib/apt/lists/*


# Expose 5601 port used by Kibana
# Expose 80 port used by apache
EXPOSE 5601 80

# Start Kibana service
CMD ["kibana","-H","0.0.0.0"]
