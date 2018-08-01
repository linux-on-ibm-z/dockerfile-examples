# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
########## Dockerfile for Drupal version 8.4.5 #########
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
# docker run --name <container_name> -p <host_port>:80 -p <host_port>:3306 -d <image_name>  
# 
# We can view the Drupal UI at http://<drupal-host-ip>:<port_number>
#
# Reference:
# https://www.drupal.org/docs/8/install/
#
##################################################################################


# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN	apt-get update && apt-get -y install \
		apache2 \
		composer \
		curl \
		libapache2-mod-php \
		php \
		php7.0-xml \
		php7.0-gd \
		php7.0-ldap \
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
	&&	wget https://ftp.drupal.org/files/projects/drupal-8.4.5.tar.gz \
	&&	tar -xvf drupal-8.4.5.tar.gz \
	&&	mkdir -p /var/www/html/Drupal \
	&&	mv drupal-8.4.5/* drupal-8.4.5/.htaccess drupal-8.4.5/.csslintrc \
		drupal-8.4.5/.editorconfig drupal-8.4.5/.eslintignore drupal-8.4.5/.eslintrc.json \
		drupal-8.4.5/.gitattributes /var/www/html/Drupal \
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

