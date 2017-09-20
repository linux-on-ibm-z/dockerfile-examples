########## Dockerfile for Magento version 2.1.8 ######
#
# Magento is an open-source e-commerce platform written in PHP.
#
# To build Magento image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start Magento server run the below command
# docker run --name <container_name> -p <port_number>:80 -p <port_number_mysql>:3306 -d <image_name>
#
# We can view the Magento UI at http://<Magento-host-ip>:<port_number>/magento2/setup
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    apache2 \
    composer \
    libapache2-mod-php7.0 \
    mysql-server \
    php7.0-mysql \
    php7.0-curl \
    php7.0-json \
    php7.0-xsl \
    php7.0-xml \
    php7.0-mcrypt \
    php7.0-mbstring \
    php7.0-intl \
    php7.0-zip \
    php7.0-gd  \

# Configure apache2	
 && chmod 766 /etc/apache2/apache2.conf \
 && cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf1 \
 && cp echo -e "ServerName localhost" >> /etc/apache2/apache2.conf \
 && cp echo -e '<Directory "/var/www/html">' >> /etc/apache2/apache2.conf \
 && cp echo -e "AllowOverride  All" >> /etc/apache2/apache2.conf \
 && cp  echo -e "</Directory>" >> /etc/apache2/apache2.conf \
 && diff -u /etc/apache2/apache2.conf1 /etc/apache2/apache2.conf  ||true \
 && a2enmod rewrite \

# Clone Magento source code 
 &&  cd /var/www/html/ \
 && chmod -R a+w /var/www/html/ \
 && git clone https://github.com/magento/magento2.git \
 && cd magento2 \
 && git checkout 2.1.8 \
 && composer install \
 
# Start mysql server and create database for Magento
 && mkdir -p /var/lib/mysql/data \
 && /usr/sbin/mysqld --initialize --user=mysql --datadir=/var/lib/mysql/data \
 && sleep 60s && mkdir -p /var/run/mysqld \
 && chown mysql:mysql /var/run/mysqld \
 && cd /var/www/html/magento2 && find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \; && chown -R :www-data . && chmod u+x bin/magento \
 && service mysql start && sleep 15s && /usr/bin/mysql -e "create database magento" \
 && /usr/bin/mysql -e "create user 'user'@'localhost' " \
 && /usr/bin/mysql -e "grant all privileges on *.* to 'user'@'localhost'" \

#  Create a script to start apache2 and mysql
 && echo 'service apache2 start && /usr/bin/mysqld_safe --user=mysql' > /start.sh \

# Clean up of unused packages
 && apt-get remove -y \
    curl  \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf  /var/lib/apt/lists/*
  
# Create volume
VOLUME /var/www/html

# Expose port for mysql and apache2
EXPOSE 80 3306

# Start mysql and apache2 server
CMD ["/bin/sh", "start.sh"]

# End of Dockerfile
