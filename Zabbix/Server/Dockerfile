# © Copyright IBM Corporation 2017, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Zabbix-server version 5.0.17 #########
#
# This Dockerfile builds a basic installation of Zabbix-server.
#
# Zabbix server is the central process of Zabbix software
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Zabbix server run the below command:
# docker run --name <container_name> -p <portnumber>:80 -d <image>
#
# Test in the browser by using the following url:
# http://<hostname>:<port_number>/zabbix
#
# Note: To login into zabbix dashboard, Use user name as "Admin" and password as "zabbix" to log in as a Zabbix superuser.
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04 AS builder

ARG ZBX_SERVER_VER=5.0.17

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/sbin/
ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

# Install dependencies
RUN     apt-get update && apt-get install -y mysql-server \
        && apt-get -y install \
                ceph \
                gcc \
                git \
                pkg-config \
                libcurl4 \
                libcurl4-openssl-dev \
                libmysqlclient-dev \
                libmysqld-dev \
                libsnmp-dev \
                libxml2-dev \
                make \
                snmp \
                snmptrapd \
                wget \
                libevent-dev \
                libpcre3-dev \
# Download and install Zabbix server
        &&      cd $SOURCE_DIR \
        &&      wget https://cdn.zabbix.com/zabbix/sources/stable/5.0/zabbix-${ZBX_SERVER_VER}.tar.gz \
        &&      tar -zxf zabbix-${ZBX_SERVER_VER}.tar.gz \
        &&      cd zabbix-${ZBX_SERVER_VER}/ \
        &&      ./configure --enable-server --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 \
        &&      make install \
        &&      cat /zabbix-${ZBX_SERVER_VER}/database/mysql/schema.sql > /zabbix-${ZBX_SERVER_VER}/database/mysql/create.sql \
        &&      cat /zabbix-${ZBX_SERVER_VER}/database/mysql/images.sql >> /zabbix-${ZBX_SERVER_VER}/database/mysql/create.sql \
        &&      cat /zabbix-${ZBX_SERVER_VER}/database/mysql/data.sql >> /zabbix-${ZBX_SERVER_VER}/database/mysql/create.sql

# Base Image
FROM s390x/ubuntu:18.04

ARG ZBX_SERVER_VER=5.0.17

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/sbin/
ENV SOURCE_DIR=/
WORKDIR $SOURCE_DIR

COPY --from=builder /zabbix-${ZBX_SERVER_VER}/src/zabbix_server/zabbix_server /usr/sbin/zabbix_server
COPY --from=builder /zabbix-${ZBX_SERVER_VER}/src/zabbix_get /usr/bin/zabbix_get
COPY --from=builder /zabbix-${ZBX_SERVER_VER}/src/zabbix_sender/ /usr/bin/zabbix_sender
COPY --from=builder /zabbix-${ZBX_SERVER_VER}/conf/zabbix_server.conf /usr/local/etc/zabbix_server.conf
COPY --from=builder /zabbix-${ZBX_SERVER_VER}/database/mysql/create.sql /usr/share/doc/zabbix-server-mysql/create.sql
COPY --from=builder /zabbix-${ZBX_SERVER_VER}/ui /usr/share/doc/ui

# Install dependencies
RUN     apt-get update && apt-get install -y mysql-server \
        && apt-get -y install \
                sudo \
                apache2 \
                libapache2-mod-php \
                libcurl4 \
                libcurl4-openssl-dev \
                libmysqlclient-dev \
                libmysqld-dev \
                libsnmp-dev \
                libxml2-dev \
                php \
                php7.2-gd \
                php7.2-ldap \
                php7.2-xml \
                php7.2-bcmath \
                php7.2-mbstring \
                php7.2-mysql \
                libevent-dev \
                libpcre3-dev \
# Enable PHP support by modifying Apache configuration file
        &&      cd /etc/apache2 \
        &&      chmod 766 apache2.conf \
        &&      echo "ServerName localhost" >> apache2.conf \
        &&      echo "AddType application/x-httpd-php .php" >> apache2.conf \
        &&      echo "<Directory />" >> apache2.conf \
        &&      echo " DirectoryIndex index.php " >> apache2.conf \
        &&      echo "</Directory>" >> apache2.conf \
# Create a 'zabbix' user required to start Zabbix server daemon
        &&      /usr/sbin/groupadd zabbix \
        &&      /usr/sbin/useradd -g zabbix zabbix \
# Installing Zabbix web interface
        &&      cd /usr/share/doc/ui/ \
        &&      mkdir -p /var/www/html/zabbix \
        &&      cp -rf * /var/www/html/zabbix/ \
        &&      cd /var/www/html/zabbix \
        &&      chown -R www-data:www-data conf \
# Create database and grant privileges to zabbix user
        &&      service mysql start  \
        &&      /usr/bin/mysql -e "create user 'zabbix'@'localhost'" \
        &&      /usr/bin/mysql -e "create database zabbix character set utf8 collate utf8_bin" \
        &&      /usr/bin/mysql -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'" \
        &&      cd /usr/share/doc/zabbix-server-mysql \
        &&      mysql -uzabbix zabbix < create.sql \
        &&      /usr/bin/mysql -e "update zabbix.items set status=1 where itemid in (select itemid from zabbix.item_preproc where type=21)" \
# Change php.ini file
        &&      sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.2/apache2/php.ini \
        &&      sed -i 's/max_input_time = 60/max_input_time = 300/g' /etc/php/7.2/apache2/php.ini \
        &&      sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php/7.2/apache2/php.ini \
        &&      sed -i "s/;date.timezone =/date.timezone = 'Asia\/Kolkata'/g" /etc/php/7.2/apache2/php.ini \
# Start apache, mysql & Zabbix server
        &&      echo 'zabbix ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && echo 'sudo service apache2 start && sudo service mysql start && zabbix_server --foreground' > /start.sh \
# Clean up cache data and remove dependencies which are not required
        &&      apt autoremove -y && apt-get clean \
        &&      rm -rf /zabbix-${ZBX_SERVER_VER}.tar.gz && rm -rf /var/lib/apt/lists/*

RUN     cd /var/www/html/zabbix \
        && chmod 733 assets

# Expose ports for apache2 & default port of Zabbix server
EXPOSE 80 10051

VOLUME /var/lib/mysql

# Switch to zabbix user
USER zabbix

# Start apache2 and mysql sever & zabbix server
CMD ["/bin/bash","/start.sh"]

# End of Dockerfile
