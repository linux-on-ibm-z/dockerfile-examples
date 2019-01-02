# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################################# Dockerfile for NGINX 1.14.2 #####################################################
#
# This Dockerfile builds a basic installation of NGINX.
# NGINX is a free, open-source, high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create container of NGINX image run the below command
# docker run --name <container name> -p <port_number>:80 -d <nginximage>
# To view the default nginx website open the link http://<hostname>:<port_number>                                                   
###############################################################################################################
# Base image
FROM s390x/ubuntu:16.04

ARG NGINX_VER=1.14.2

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

# Installing dependencies and NGINIX
RUN apt-get update && apt-get install -y \
	gcc \
	libpcre3-dev \
	libssl-dev \
	make \
	openssl \
	tar \
	wget \	
	zlib1g \
	zlib1g-dev \
 && wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz \
 && tar xvf nginx-${NGINX_VER}.tar.gz \
 && cd nginx-${NGINX_VER} \
 && ./configure \
 && make  \
 && make install  \
# Clean up Cache data, unused packages and source files 
 && apt-get remove -y \
	make \
	wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/nginx-${NGINX_VER}.tar.gz  /root/nginx-${NGINX_VER} \
 && rm -rf /var/lib/apt/lists/*

# Add VOLUMEs to allow backup error logs, configuration and server directory content
VOLUME  ["/var/log/nginx/","/etc/nginx","/var/www/html"]

# For standard non-secured "http" is port 80, Netscape chose 443 to be the default port used by secure http.
EXPOSE 80 443 8080

ENV NGINX_HOME=/usr/local/nginx/
ENV PATH=$PATH:$NGINX_HOME/sbin

# Start NGINX Server
CMD ["nginx","-g","daemon off;"]

# End of Dockerfile
