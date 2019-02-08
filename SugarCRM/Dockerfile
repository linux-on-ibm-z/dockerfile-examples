########## Dockerfile for SugarCRM version 6.5.26 #########
#
# This Dockerfile builds a basic installation of SugarCRM.
#
# SugarCRM is a Customer Relationship Management platform which is widely used and recognized as the most successful tool for managing customers by many large companies over the world.
# Sugar provides an easy-to-use CRM interface focused on features that matter and nothing more.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start container & Complete SugarCRM installation at http://<Sugar-host-ip>:<port_number>/Sugar/install.php
# docker run -d --name <container_name> -p <host_port>:80 -p <host_port>:3306 <image>
# e.g. docker run -d --name Sugar -p 88:80 -p 3307:3306 sugar
# 
# Official website: https://www.sugarcrm.com/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN  apt-get update  \
  && apt-get install -y  \ 
		apache2 \
		curl \
		libapache2-mod-php7.0 \
		mysql-server \
		php7.0 \
        php7.0-mysql \
        php7.0-mcrypt \
        php7.0-cli \
       	php7.0-common \
        php7.0-curl \
        php7.0-dev \
		php7.0-gd \
		php7.0-imap \
		php7.0-mbstring \
		php7.0-xml \
		php7.0-zip \
		unzip \
		wget \

# Modifying Apache configuration file
    &&	cd /etc/apache2 \
	&&	chmod 755 apache2.conf \
	&&	echo "AddType application/x-httpd-php .php" >> apache2.conf \
	&&	echo "ServerName localhost" >> apache2.conf \
	&&	echo "<Directory "/var/www/html/">" >> apache2.conf \
	&&  echo "AllowOverride  All" >> apache2.conf \
	&&	echo "</Directory>" >> apache2.conf \
	&&  a2enmod rewrite \
	
# Change in Memory requirements	
	&&  sed -i 's/memory_limit = 128M/memory_limit = 768M/g' /etc/php/7.0/apache2/php.ini \
	&&	sed -i 's/post_max_size = 8M/post_max_size = 24M/g' /etc/php/7.0/apache2/php.ini \
	&&	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php/7.0/apache2/php.ini \
	&&	sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/g' /etc/php/7.0/apache2/php.ini \
	&&  phpenmod imap && phpenmod zip && phpenmod mbstring && service apache2 start \
	
# Start mysql server and create database for Sugar
    &&  service mysql start && sleep 15s && mysql -e "create database sugarcrm;" \
    &&  mysql -e "create user sugar@localhost identified by 'sugar';" \
    &&  mysql -e "grant all privileges on sugarcrm.* to 'sugar'@'localhost' identified by 'sugar';" \
 
# Download and build source code of Sugar
    &&  chown -R www-data:www-data /var/www/html/ && chmod -R a+w /var/www/html/ && cd /var/www/html/ \
	&&  wget https://downloads.sourceforge.net/project/sugarcrm/OldFiles/1%20-%20SugarCRM%206.5.X/SugarCommunityEdition-6.5.X/SugarCE-6.5.26.zip \
    &&  unzip SugarCE-6.5.26.zip \
    &&  mv SugarCE-Full-6.5.26 Sugar && chmod -R a+w Sugar \
	
# Clean up of unused packages
    &&  apt-get remove -y \
            curl  \
            unzip \
            wget \
			  
    && apt-get autoremove -y \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf  /var/lib/apt/lists/* /var/www/html/SugarCE-6.5.26.zip 
  
# Define mount point
VOLUME /var/www/html

# Expose ports for mysql and apache2
EXPOSE 80 3306 

# Start apache2 and mysql sever 
CMD service mysql start && apachectl -D FOREGROUND

# End of Dockerfile
