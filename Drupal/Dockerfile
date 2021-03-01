# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)


########## Dockerfile for Drupal version 8.8.4 #########
#
# This Dockerfile builds a basic installation of Drupal.
#
# Drupal is content management software. It's used to make many of the websites and applications you use every day. 
# Drupal has great standard features, like easy content authoring, reliable performance, and excellent security. 
# But what sets it apart is its flexibility; modularity is one of its core principles.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Drupal run the below command:
# docker run --name <container_name> -p <host_port>:80 -d <image_name>  
# 
# We can view the Drupal UI at http://<drupal-host-ip>:<port_number>
#
# Reference:
# https://www.drupal.org/docs/8/install/
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG DRUPAL_VERSION=8.8.4

ENV SOURCE_DIR=/tmp/source DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN	apt-get update && apt-get -y install \
		apache2 \
		composer \
		curl \
		libapache2-mod-php \
		php \
		php7.2-xml \
		php7.2-gd \
		php7.2-ldap \
		php7.2-curl \
		php-mysql \
		php-bcmath \
		php-mbstring \
		tar \
		unzip \
		wget \
	
# Enable PHP support by modifying Apache configuration file
	&&	cd /etc/apache2 \
	&&	chmod 766 apache2.conf \
	&&	echo "ServerName localhost" >> apache2.conf \
	&&	echo "AddType application/x-httpd-php .php" >> apache2.conf \
	&&	echo "<Directory />" >> apache2.conf \
	&&	echo " DirectoryIndex index.php " >> apache2.conf \
	&&	echo "</Directory>" >> apache2.conf \
	&&	sed -ie '166s/None/All/' apache2.conf \
	&& 	line="\/var\/www\/html" \
	&& 	line_new="\/var\/www\/html\/Drupal" \
	&&	a2enmod rewrite \
	&& 	sed -i "s/$line/$line_new/g" /etc/apache2/sites-available/000-default.conf \
	
# Download and install Drupal
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	wget https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz \
	&&	tar -xvf drupal-${DRUPAL_VERSION}.tar.gz \
	&&	mkdir -p /var/www/html/Drupal \
	&&	mv drupal-${DRUPAL_VERSION}/* drupal-${DRUPAL_VERSION}/.htaccess drupal-${DRUPAL_VERSION}/.csslintrc \
		drupal-${DRUPAL_VERSION}/.editorconfig drupal-${DRUPAL_VERSION}/.eslintignore drupal-${DRUPAL_VERSION}/.eslintrc.json \
		drupal-${DRUPAL_VERSION}/.gitattributes /var/www/html/Drupal \
	&&	cd /var/www/html/Drupal \
	&& 	composer install \
	
# Configure missing files
	&&	mkdir sites/default/files \
	&&	chmod a+w sites/default/files \
	&&	chmod a+w sites/default \
	&&	cp sites/default/default.settings.php sites/default/settings.php \
	&&	chmod a+w sites/default/settings.php \
	
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		composer \
		unzip \
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCE_DIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
EXPOSE 80 

VOLUME /var/www/html

CMD apachectl -D FOREGROUND
	
# End of Dockerfile
