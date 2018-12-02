# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for MySQL version 5.7.24 ############################################
#
# This Dockerfile builds a basic installation of MySQL.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Mysql service using this image, use following command and set required environment variables :
# docker run --name <container name> -p <port>:3306 -d <image name>
#
##################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV DEBIAN_FRONTEND noninteractive

# Install mysql-server with dependencies and clean up cache data.
RUN apt-get update && apt-get -y install \
	mysql-server \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \

# Configure mysql database (kindly check comment section above)
	&& chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf \
	&& sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf 

# Expose the default port
EXPOSE 3306
VOLUME /var/lib/mysql
# START MYSQL SERVER
CMD service mysql start && tail -f /var/log/mysql/error.log

#END OF DOCKERFILE
