# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Joomla version 3.9.10 ######
#
# Joomla is an online, open source website creation tool written in PHP.
#
# To build Joomla image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start Joomla server run the below command
# docker run --name <container_name> -p <port_number>:80 -p <port_number_mysql>:3306 -d <image_name>
#
# We can view the Joomla UI at http://<Joomla-host-ip>:<port_number>/Joomla
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)
ENV DEBIAN_FRONTEND noninteractive

ARG JOOMLA_VER=3.9.10

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    apache2 \
    curl  \
    libapache2-mod-php7.0 \
    libapache2-mod-perl2 \
    mysql-server \
    php7.0 \
    php7.0-mysql \
    php7.0-mcrypt \
    php7.0-cli \
    php7.0-common \
    php7.0-curl \
    php7.0-dev \
    unzip \
    wget \

# Configure apache2 server
 && chmod 766 /etc/apache2/apache2.conf \
 && cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf1 \
 && cp echo -e "ServerName localhost" >> /etc/apache2/apache2.conf \
 && cp echo -e '<Directory "/var/www/html">' >> /etc/apache2/apache2.conf \
 && cp echo -e "AllowOverride  All" >> /etc/apache2/apache2.conf \
 && cp  echo -e "</Directory>" >> /etc/apache2/apache2.conf \
 && diff -u /etc/apache2/apache2.conf1 /etc/apache2/apache2.conf  ||true \
 && a2enmod rewrite \

# Download and install Joomla
 &&  cd /var/www/html/ \
 && chmod -R a+w /var/www/html/ \
 && mkdir Joomla \
 && cd Joomla \
 && wget https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_VER}/Joomla_${JOOMLA_VER}-Stable-Full_Package.zip \
 && unzip Joomla_${JOOMLA_VER}-Stable-Full_Package.zip  \
 && chmod a+w /var/www/html/Joomla/ \
 && mv installation/configuration.php-dist installation/configuration.php \

# Start mysql server and create database for Joomla
 &&  mkdir -p /var/lib/mysql/data \
 && /usr/sbin/mysqld --initialize --user=mysql --datadir=/var/lib/mysql/data \
 && sleep 60s && mkdir -p /var/run/mysqld \
 && chown mysql:mysql /var/run/mysqld \
 && service mysql start && sleep 15s && /usr/bin/mysql -e "create database Joomla" \
 && /usr/bin/mysql -e "create user 'user'@'localhost' " \
 && /usr/bin/mysql -e "grant all privileges on *.* to 'user'@'localhost'" \

# Create a script to start apache2 and mysql
 && echo 'chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && service apache2 start && /usr/bin/mysqld_safe --user=mysql' > /start.sh \

# Clean up of unused packages
 && apt-get remove -y \
    curl  \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf  /var/lib/apt/lists/* \
 && rm  /var/www/html/Joomla/Joomla_${JOOMLA_VER}-Stable-Full_Package.zip
# Create volume
VOLUME /var/www/html

# Expose ports for mysql and apache2
EXPOSE 80 3306

# Start apache2 and mysql server
CMD ["/bin/sh", "start.sh"]
