########## Dockerfile for Drupal version 8.4.4 #########
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
# docker run --name <container_name> -v <host_path>:/var/www/html -p <host_port>:80 -p <host_port>:3306 -d <image_name>  
# 
# We can view the Drupal UI at http://<drupal-host-ip>:<port_number>
#
# Reference:
# https://www.drupal.org/docs/8/install/
#
##################################################################################
#	-: Configure Database :-
#
#	1.Create a new database for your site. (Change the username and databasename.)
#		mysql -u username -p -e "CREATE DATABASE databasename CHARACTER SET utf8 COLLATE utf8_general_ci";
#
#	2.Create the user and set the permissions using the following command:
#		mysql -e "CREATE USER username@localhost IDENTIFIED BY 'password';"
#
#		mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON databasename.* TO 'username'@'localhost' IDENTIFIED BY 'password';"
#
#	NOTE:-
#		In this case:
#	    	'databasename' is the name of your database
#	    	'username' is the username of your MySQL user account
#	    	'localhost' is the host where Drupal is installed
#	    	'password' is the password required for that username
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
		mysql-server \
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
	&&	wget https://ftp.drupal.org/files/projects/drupal-8.4.4.tar.gz \
	&&	tar -xvf drupal-8.4.4.tar.gz \
	&&	mkdir -p /var/www/html/Drupal \
	&&	mv drupal-8.4.4/* drupal-8.4.4/.htaccess drupal-8.4.4/.csslintrc \
		drupal-8.4.4/.editorconfig drupal-8.4.4/.eslintignore drupal-8.4.4/.eslintrc.json \
		drupal-8.4.4/.gitattributes /var/www/html/Drupal \
	&&	cd /var/www/html/Drupal \
	&& 	composer install \
	
# Configure missing files
	&&	mkdir sites/default/files \
	&&	chmod a+w sites/default/files \
	&&	chmod a+w sites/default \
	&&	cp sites/default/default.settings.php sites/default/settings.php \
	&&	chmod a+w sites/default/settings.php \
	
# Configure mysql database (kindly check comment section above)
	&&	service mysql start \
	&&	sleep 10 \
	&&	mysql -e "CREATE USER drupal@localhost IDENTIFIED BY 'drupal';" \
	&&	mysql -e "CREATE DATABASE drupal CHARACTER SET utf8 COLLATE utf8_general_ci;" \
	&&	mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, \
			CREATE TEMPORARY TABLES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY 'drupal';" \
	
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
	
EXPOSE 80 3306

VOLUME /var/www/html

CMD service mysql start && apachectl -D FOREGROUND
	
# End of Dockerfile
