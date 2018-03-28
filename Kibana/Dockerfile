############################### Dockerfile for Kibana version 6.2.2 ##########################################
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
ENV PATH=/ibm/node/bin:/usr/share/kibana/bin:$PATH
# Install the dependencies and NodeJS
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    tar \
    unzip \
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/nodejs/6.12.2.0/linux/s390x/ibm-6.12.2.0-node-v6.12.2-linux-s390x.bin \
 && echo "LICENSE_ACCEPTED=TRUE\nUSER_INSTALL_DIR=/ibm/node\n-fileOverwrite_/ibm/node/_node_installation/uninstall.lax=Yes" > installer.properties \
 && cat installer.properties \
 && chmod +x ibm-6.12.2.0-node-v6.12.2-linux-s390x.bin \
 && ./ibm-6.12.2.0-node-v6.12.2-linux-s390x.bin -f installer.properties -i silent \
 && node -v \

# Download and setup Kibana
 && cd /root/ && wget https://artifacts.elastic.co/downloads/kibana/kibana-6.2.2-linux-x86_64.tar.gz \
 && tar xvf kibana-6.2.2-linux-x86_64.tar.gz \
 && mv /root/kibana-6.2.2-linux-x86_64 kibana-6.2.2 \
 && cd /root/kibana-6.2.2 \
 && mv node node_old \
 && ln -s /ibm/node node \
 && mkdir /etc/kibana \
 && cp config/kibana.yml /etc/kibana \
 && mv /root/kibana-6.2.2/ /usr/share/kibana \

# Cleanup Cache data , unused packages and source files
 && apt-get remove -y \
    unzip \
    wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/kibana-6.2.2-linux-x86_64.tar.gz /root/node-v6.2.2-linux-s390x.tar.gz \
 && rm -rf /var/lib/apt/lists/*


# Expose 5601 port used by Kibana
# Expose 80 port used by apache
EXPOSE 5601 80

# Start Kibana service
CMD ["kibana","-H","0.0.0.0"]
