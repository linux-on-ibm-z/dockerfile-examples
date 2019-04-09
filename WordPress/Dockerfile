# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for WordPress version 5.1.1 ############################
#
# WordPress is an online, open source website creation tool written in PHP.
#
# To build WordPress image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start WordPress server run the below command
# docker run --name <container_name> -p <port_number>:80 -p <port_number_mysql>:3306 -d <image_name>
#
# We can view the Wordpress UI at http://<wordpress-host-ip>:<port_number>
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

ARG WORDPRESS_VER=5.1.1

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    apache2 \
    curl \
    git \
    libapache2-mod-php \
    mysql-server \
    php \
    php-mysql \

# Configure apache2 server
 && echo "AddType application/x-httpd-php .php" >> /etc/apache2/apache2.conf \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && echo "<Directory />" >> /etc/apache2/apache2.conf \
 && echo " DirectoryIndex index.php " >> /etc/apache2/apache2.conf \
 && echo "</Directory>" >> /etc/apache2/apache2.conf \
 && line="\/var\/www\/html" \
 && line_new="\/var\/www\/html\/WordPress" \
 && sed -i "s/$line/$line_new/g" /etc/apache2/sites-available/000-default.conf \

# Download Wordpress application into apache2 server
 && cd /var/www/html && git clone git://github.com/WordPress/WordPress.git \
 && cd WordPress && git checkout $WORDPRESS_VER \
 && mv wp-config-sample.php wp-config.php \
 && sed -i 's/localhost/127.0.0.1/' wp-config.php \
 && sed -i 's/database_name_here/WORDPRESS/' wp-config.php \
 && sed -i 's/username_here/Wordpress/' wp-config.php \
 && sed -i 's/password_here/password/' wp-config.php \

# Initialize database server
 && mkdir -p /var/lib/mysql/data \
 && /usr/sbin/mysqld --initialize --user=mysql --datadir=/var/lib/mysql/data \
 && sleep 60s && mkdir -p /var/run/mysqld \
 && chown mysql:mysql /var/run/mysqld \

# Creating script for starting apache2 server and mysql
 && service mysql start && sleep 15s && /usr/bin/mysql -e "create database WORDPRESS" \
 && /usr/bin/mysql -e "create user 'Wordpress'@'localhost' identified by 'password'" \
 && /usr/bin/mysql -e "grant all privileges on WORDPRESS.* to 'Wordpress'@'localhost' identified by 'password' with GRANT OPTION" \
 && echo 'service apache2 start && /usr/bin/mysqld_safe --user=mysql' > /start.sh \

# Clean up of unused packages
 && apt-get remove -y \
    curl \
    git \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf  /var/lib/apt/lists/*

VOLUME /var/www/html

EXPOSE 80 3306

CMD ["/bin/sh", "start.sh"]

# End of Dockerfile
