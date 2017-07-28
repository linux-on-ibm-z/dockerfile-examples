############################ Dockerfile for MySQL version 5.7.18 ############################################
#
# This Dockerfile builds a basic installation of MySQL.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Mysql service using this image, use following command:
# docker run --name <container name> -p <port>:3306 -d <image name>
#
##################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set default password for mysql-server installation.
RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections \
 && echo mysql-server mysql-server/root_password_again password root | debconf-set-selections

# Install mysql-server with dependencies and clean up cache data.
RUN apt-get update && apt-get -y install \
	mysql-server \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the default port
EXPOSE 3306

# Start mysql server and tail error log 
ENTRYPOINT service mysql start && tail -f /var/log/mysql/error.log

# End of Dockerfile
