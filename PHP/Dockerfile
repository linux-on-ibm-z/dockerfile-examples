# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
# This dockerfile is no longer supported. Please find latest information from https://www.ibm.com/community/z/open-source-software/
#
############################# Dockerfile for PHP 7.3.7 ###############################
#
# This Dockerfile builds a basic installation of PHP
#
#PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. 
#PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. 
#PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or 
#as a common gateway interface (CGI).
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Use the following command to start PHP container.
# docker run --name <container name> -it <image name> /bin/bash
#
#
######################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

WORKDIR "/root"

ENV PATH=/usr/local/bin:$PATH

RUN apt-get update && apt-get install -y \
   autoconf \
   automake \
   bison \
   flex \
   gcc \
   git \
   libbz2-dev \
   libcurl4-gnutls-dev \
   libdb-dev \
   libfreetype6-dev \
   libgdbm-dev \
   libgmp3-dev \
   libjpeg-dev \
   libldap2-dev \
   libmysqlclient-dev \
   libpcre3-dev \
   libpng-dev \
   libpq-dev \
   libreadline-dev \
   libsasl2-dev \
   libsnmp-dev \
   libssl-dev \
   libtool-bin \
   libxml2-dev \
   libxpm-dev \
   libxslt1-dev \
   libzip-dev \
   make \
   openssl \
   pkg-config \
   re2c \
   snmp-mibs-downloader \
   unixodbc-dev \
   vim \
   ed \
   patch \

   # Download PHP
   && cd /root && git clone git://github.com/php/php-src.git \
   && cd php-src && git checkout tags/php-7.3.7 \
   && ln -sf /usr/lib/s390x-linux-gnu/libldap.so /usr/lib/libldap.so \
   && ln -sf /usr/lib/s390x-linux-gnu/liblber.so /usr/lib/liblber.so \
   && ln -sf /usr/include/s390x-linux-gnu/gmp.h /usr/include/gmp.h \

   # apply patch
   && sed -i 's/\(argName.length()\)/\1 * sizeof(UChar)/g' ext/intl/msgformat/msgformat_helpers.cpp \
   && sed -i 's/\(key.length()\)/\1 * sizeof(UChar)/g' ext/intl/msgformat/msgformat_helpers.cpp \
   && sed -i 's/\(sizeof(key)\) - 1/\1/g' ext/sockets/sendrecvmsg.c \

   # Configure and Install PHP
   && cd /root/php-src \
   && ./buildconf --force \
   && ./configure --datadir=/usr/local/share/php --localstatedir=/var --mandir=/usr/local/share/man --prefix=/usr/local --sysconfdir=/usr/local/etc --enable-bcmath --enable-calendar --enable-ctype --with-curl --enable-dba=shared --enable-exif --enable-filter --enable-flatfile --enable-fpm --enable-ftp  --enable-inifile --enable-intl --enable-mbstring --enable-mysqlnd --enable-opcache --enable-pcntl --enable-shmop --enable-simplexml --enable-sockets --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-xmlreader --enable-xmlwriter --enable-zend-signals --enable-zip --disable-phpdbg --disable-phpdbg-webhelper --with-bz2 --with-config-file-path=/usr/local/etc --with-config-file-scan-dir=/usr/local/etc/conf.d --with-freetype-dir --with-gd --with-gdbm --with-gettext --with-gmp --with-iconv --with-jpeg-dir --with-kerberos --with-ldap --with-ldap-sasl  --with-mysql-sock=/var/lib/mysql/mysql.sock --with-mysqli=mysqlnd --with-openssl --with-pcre-regex --with-pdo-mysql=mysqlnd --with-pdo-odbc=unixODBC,/usr --with-pdo-pgsql --with-pdo-sqlite --with-pgsql --with-png-dir --with-readline --with-snmp --with-sqlite3 --with-unixODBC=/usr --with-xpm-dir=/usr --with-xsl --with-zlib --without-pcre-jit \
   && make clean \
   && make -j$(cat /proc/cpuinfo | grep 'processor ' | wc -l) \
   && make install \
   && install -m644 php.ini-production /usr/local/etc/php.ini \
   && sed -i 's@php/includes"@&\ninclude_path = ".:/usr/local/lib/php"@' /usr/local/etc/php.ini \

   # Prepare conf files
   && chmod 776 /usr/local/etc/php-fpm.conf.default \
   && cd /usr/local/etc \
   && sed -i '18i pid = run/php-fpm.pid' php-fpm.conf.default \
   && mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf \
   && mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf \
   && chmod 776 /root/php-src/sapi/fpm/php-fpm.service.in \
   && cd /root/php-src/sapi/fpm/ \
   && sed -i '10d' php-fpm.service.in \
   && sed -i '10i Type=simple' php-fpm.service.in \
   && sed -i '11d' php-fpm.service.in \
   && sed -i '11i PIDFile=/var/run/php-fpm.pid' php-fpm.service.in \
   && sed -i '12d' php-fpm.service.in \
   && sed -i '12i ExecStart=/usr/local/sbin/php-fpm --nodaemonize --fpm-config /usr/local/etc/php-fpm.conf' php-fpm.service.in \
   && cp /root/php-src/sapi/fpm/php-fpm.service.in /lib/systemd/system/php-fpm.service \
   && chmod 776  /usr/local/etc/php.ini \
   && cd /usr/local/etc/ \
   && sed -i '1801i zend_extension=opcache.so' php.ini \

   # Cleanup unwanted packages and source files
   && apt-get remove -y \
   autoconf \
   automake \
   bison \
   flex \
   git \
   make \
   pkg-config \
   re2c \
   && apt autoremove -y \
   && apt-get clean && rm -rf /var/lib/apt/lists/* \
   && rm -rf /root/php-src

CMD php -v

