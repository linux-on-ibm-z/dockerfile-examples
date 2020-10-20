# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
########################################## Dockerfile for WordPress 5.3.2 ############################################
#
# To build this image, run docker build from the directory containing this Dockerfile:
# 
#       docker build -t wordpress:5.3.2 .
#
# Examples configurations for WordPress docker image using MySQL container:
# Set up docker network:
#       
#       docker network create wp_network
#
# Set up MySQL container and create WordPress database, user and password:
#
#       docker run --name mysql \
#           -e MYSQL_ROOT_PASSWORD=rootpass \
#           -e MYSQL_DATABASE=wordpress \
#           -e MYSQL_USER=wordpress \
#           -e MYSQL_PASSWORD=wppass \
#           --network wp_network -d mysql:5.7
# 
# Set up WordPress container with MySQL container:
#
#       docker run --name wordpress \
#           -e WORDPRESS_DB_HOST=mysql:3306 \
#           -e WORDPRESS_DB_NAME=wordpress \
#           -e WORDPRESS_DB_USER=wordpress \
#           -e WORDPRESS_DB_PASSWORD=wppass \
#           --network wp_network -p 8080:80 -d wordpress:5.3.2
#
# Then, access WordPress admin page via: https://host-ip:8080
# 
# For more WordPress docker configuration, please visit the official WordPress dockerhub webpage:
# 
#       https://hub.docker.com/_/wordpress
#
################################################################################################################

FROM s390x/ubuntu:18.04
ENV WORDPRESS_VERSION 5.3.2
ENV WORDPRESS_SHA1 fded476f112dbab14e3b5acddd2bcfa550e7b01b
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    apache2 \
    curl \
    ghostscript \
    libapache2-mod-php \
    && rm /var/www/html/index.html
# Install PHP 7 with extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN apt-get update && apt-get install -y \
    php \
    php-common \
    php-curl \
    php-fpm \
    php-json \
    php-mbstring \
    php-mysql \
    php-imagick \
    php-ssh2 \
    php-xml \
    php-zip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/apache2-foreground -fSL "https://raw.githubusercontent.com/docker-library/php/master/apache2-foreground" \
    && chmod +x /usr/local/bin/apache2-foreground \
    && a2enmod rewrite expires \
    && set -ex \
    && curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    # Upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    && chown -R www-data:www-data /usr/src/wordpress
VOLUME /var/www/html
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
WORKDIR /var/www/html
EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
