# © Copyright IBM Corporation 2017, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################## Dockerfile for Magento version 2.3.4 ###################################
#
# Magento is an open-source e-commerce platform written in PHP.
#
# To build Magento image from the directory containing this Dockerfile
#
# docker build -t <image_name> .
#
# To start Magento server run the below command
# docker run --name <container_name> -p <port_number>:80 -p <port_number_mysql>:3306 -d <image_name>
#
# We can view the Magento UI at http://<Magento_host_IP>:<Port_number>/magento2/setup
#
###############################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV DEBIAN_FRONTEND noninteractive

ARG MAGENTO_VER=2.3.4
ARG MYSQL_PASSWD=temp_pass

# Install dependencies
RUN apt-get update -y && apt-get install -y \
    apache2 \
    composer \
    git \
    gzip \
    libapache2-mod-php \
    libssl-dev \
    lsof \
    mysql-server \
    php7.2 \
    php7.2-bcmath \
    php7.2-curl \
    php7.2-gd \
    php7.2-intl \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-soap \
    php7.2-xml \
    php7.2-xsl \
    php7.2-zip \
    sed \
    tar \
    unzip \

# Configure apache2
 && chmod 766 /etc/apache2/apache2.conf \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && echo '<Directory "/var/www/html">' >> /etc/apache2/apache2.conf \
 && echo "AllowOverride  All" >> /etc/apache2/apache2.conf \
 && echo "</Directory>" >> /etc/apache2/apache2.conf \
 && a2enmod rewrite \
 && a2enmod php7.2 \

# Install Magento
 && cd /var/www/html/ \
 && chmod -R a+w /var/www/html/ \
 && git clone https://github.com/magento/magento2.git \
 && cd magento2 \
 && git checkout $MAGENTO_VER \
# to fix issue with github repo - see https://github.com/magento/magento2/issues/24937
 && composer update symfony/service-contracts \
 && composer install --no-plugins --no-scripts \
 && find var vendor generated pub/static pub/media app/etc -type f -exec chmod g+w {} + \
 && find var vendor generated pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
 && chown -R :www-data . && chmod u+x bin/magento \
 && chmod g+wsx generated/ \

# Start MySQL server and create database for Magento and set root password
 && service mysql start \
 && mysql -e "CREATE USER magento IDENTIFIED BY 'magento';" \
 && mysql -e "CREATE DATABASE magento;" \
 && mysql -e "GRANT ALL ON magento.* TO 'magento';" \
 && mysql -e "FLUSH PRIVILEGES;" \
 && mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWD';" \

# Clean up of unused packages
 && apt-get remove -y \
    git \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf  /var/lib/apt/lists/*

# Create volume
VOLUME /var/www/html /var/lib/mysql

# Expose port for mysql and apache2
EXPOSE 80 3306

# Start mysql and apache2 server
ENTRYPOINT service mysql start && apache2ctl -D FOREGROUND

# End of Dockerfile
