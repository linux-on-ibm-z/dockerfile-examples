########## Dockerfile for Keystone version 11.0.3 #########
#
# This Dockerfile builds a basic installation of Keystone.
#
# Keystone is an OpenStack service that provides API client authentication, service discovery, and distributed 
# multi-tenant authorization by implementing OpenStack’s Identity API.
#
# To build this image, from the directory containing this Dockerfile.
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Keystone run the below command:
# docker run --name <container_name> -p 35357:<host_port> -p 5000:<host_port> -d <image>  
# 
# Reference:
# https://docs.openstack.org/keystone/pike/
#
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source DEBIAN_FRONTEND=noninteractive OS_KEYSTONE_CONFIG_DIR=/etc/keystone \
	OS_USERNAME=admin \
	OS_PASSWORD=ADMIN_PASS \
	OS_PROJECT_NAME=admin \
	OS_USER_DOMAIN_NAME=Default \
	OS_PROJECT_DOMAIN_NAME=Default \
	OS_AUTH_URL=http://127.0.0.1:35357/v3 \
	OS_IDENTITY_API_VERSION=3

# Install dependencies
RUN	apt-get update && apt-get install -y \
		apache2 \
		apache2-dev \
		bison \
		build-essential \
		cmake \
		curl \
		dh-autoreconf \
		gcc \
		git \
		libapache2-mod-wsgi \
		libboost-dev \
		libboost-program-options-dev \
		libffi-dev \
		libncurses-dev \
		libpcre3-dev \
		libpq-dev \
		libssl-dev \
		libxslt-dev \
		make \
		mysql-server \
		net-tools \
		openssl \
		python-dev \
		python-ldap \
		python-lxml \
		python-mysqldb \
		python-pkgconfig  \
		python-psycopg2 \
		python-setuptools \
		scons \
		tar \
		wget \
	&&	easy_install pip \
	&&	pip install \
		cryptography==2.0.3 \
		functools32 \
		mod_wsgi \
		pika==0.10.0 \
		python-memcached \
		python-openstackclient \
		requests==2.10.0 \
		
# Configure and start MariaDB server
	&&	mkdir -p  /var/log/mysql \
	&&	/usr/sbin/mysqld --initialize --user=mysql --datadir=/var/lib/mysql/data \
	&&	sleep 60s \
	&&  mkdir -p /var/run/mysqld \
	&&	chown -R mysql:mysql /var/run/mysqld \
	&&	service mysql start \
	&&	sleep 60s \
	
# Create user and grant privileges on Keystone database
	&&	/usr/bin/mysql -e "CREATE DATABASE keystone" \
	&&	/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone'" \
	&&	/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone'" \
	
# Download source code and install Keystone
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/openstack/keystone.git \
	&&	cd keystone/ \
	&&	git checkout 11.0.3 \
	&&	pip install -r requirements.txt \
	&&	pip install -r test-requirements.txt  \
	&&	python setup.py install \
	
# Configure Keystone
	&&	cp -r etc/ /etc/keystone \
	&&	cd /etc/keystone/ \
	&&	mv keystone.conf.sample keystone.conf \
	&&	mv logging.conf.sample logging.conf \
	
# Edit keystone.conf file as shown below
	&&	sed -i "714i connection = mysql://keystone:keystone@127.0.0.1/keystone" /etc/keystone/keystone.conf \
	&&	sed -i "2834i provider = fernet" /etc/keystone/keystone.conf \

# Populate Keystone database
	&&	keystone-manage db_sync \
	
# Initialize fernet key repository
	&&	useradd -m keystone \
	&&	usermod -aG keystone keystone \
	&&	mkdir -p /etc/keystone/fernet-keys \
	&&	chown -R keystone:keystone fernet-keys \
	&&	keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone \
	&&	keystone-manage credential_setup --keystone-user keystone --keystone-group keystone \
	
# Bootstrap the Identity service
	&&	keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
		--bootstrap-admin-url http://127.0.0.1:35357/v3/ \
		--bootstrap-internal-url http://127.0.0.1:5000/v3/ \
		--bootstrap-public-url http://127.0.0.1:5000/v3/ \
		--bootstrap-region-id RegionOne \
	
# Add below content at end of /etc/apache2/apache2.conf file
	&&	sed -i "\$a ServerName 127.0.0.1" /etc/apache2/apache2.conf \
	
# Add wsgi-keystone.conf
	&&	cd /etc/apache2/ \
	&&	mkdir -p sites-available \
	&&	mkdir -p sites-enabled \
	&&	cd sites-available/ \
	&&	touch wsgi-keystone.conf \
	
	&& 	echo "Listen 5000" >> ~/wsgi-keystone.conf \
	&& 	echo "Listen 35357" >> ~/wsgi-keystone.conf \
	&& 	echo "" >> ~/wsgi-keystone.conf \
	&& 	echo "<VirtualHost *:5000>" >> ~/wsgi-keystone.conf \
	&& 	echo "WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}" >> ~/wsgi-keystone.conf \
	&& 	echo "WSGIProcessGroup keystone-public" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIScriptAlias / /usr/local/bin/keystone-wsgi-public" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIApplicationGroup %{GLOBAL}" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIPassAuthorization On" >> ~/wsgi-keystone.conf \
	&& 	echo  "LimitRequestBody 114688" >> ~/wsgi-keystone.conf \
	&& 	echo  "<IfVersion >= 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  '	ErrorLogFormat "%{cu}t %M"' >> ~/wsgi-keystone.conf \
	&& 	echo  "</IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "ErrorLog /var/log/apache2/keystone.log" >> ~/wsgi-keystone.conf \
	&& 	echo  "CustomLog /var/log/apache2/keystone_access.log combined" >> ~/wsgi-keystone.conf \
	&& 	echo  "" >> ~/wsgi-keystone.conf \
	&& 	echo  "<Directory /usr/local/bin>" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  <IfVersion >= 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Require all granted" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  </IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  <IfVersion < 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Order allow,deny" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Allow from all" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  </IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "</Directory>" >> ~/wsgi-keystone.conf \
	&& 	echo "</VirtualHost>" >> ~/wsgi-keystone.conf \
	&& 	echo "" >> ~/wsgi-keystone.conf \
	&& 	echo "<VirtualHost *:35357>" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIProcessGroup keystone-admin" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIScriptAlias / /usr/local/bin/keystone-wsgi-admin" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIApplicationGroup %{GLOBAL}" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIPassAuthorization On" >> ~/wsgi-keystone.conf \
	&& 	echo  "LimitRequestBody 114688" >> ~/wsgi-keystone.conf \
	&& 	echo  "<IfVersion >= 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  '	ErrorLogFormat "%{cu}t %M"' >> ~/wsgi-keystone.conf \
	&& 	echo  "</IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "ErrorLog /var/log/apache2/keystone.log" >> ~/wsgi-keystone.conf \
	&& 	echo  "CustomLog /var/log/apache2/keystone_access.log combined" >> ~/wsgi-keystone.conf \
	&& 	echo  "" >> ~/wsgi-keystone.conf \
	&& 	echo  "<Directory /usr/local/bin>" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  <IfVersion >= 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Require all granted" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  </IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  <IfVersion < 2.4>" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Order allow,deny" >> ~/wsgi-keystone.conf \
	&& 	echo  "		  Allow from all" >> ~/wsgi-keystone.conf \
	&& 	echo  "	  </IfVersion>" >> ~/wsgi-keystone.conf \
	&& 	echo  "</Directory>" >> ~/wsgi-keystone.conf \
	&& 	echo "</VirtualHost>" >> ~/wsgi-keystone.conf \
	&& 	echo "" >> ~/wsgi-keystone.conf \
	&& 	echo "Alias /identity /usr/local/bin/keystone-wsgi-public" >> ~/wsgi-keystone.conf \
	&& 	echo "<Location /identity>" >> ~/wsgi-keystone.conf \
	&& 	echo  "SetHandler wsgi-script" >> ~/wsgi-keystone.conf \
	&& 	echo  "Options +ExecCGI" >> ~/wsgi-keystone.conf \
	&& 	echo  "" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIProcessGroup keystone-public" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIApplicationGroup %{GLOBAL}" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIPassAuthorization On" >> ~/wsgi-keystone.conf \
	&& 	echo "</Location>" >> ~/wsgi-keystone.conf \
	&& 	echo "" >> ~/wsgi-keystone.conf \
	&& 	echo "Alias /identity_admin /usr/local/bin/keystone-wsgi-admin" >> ~/wsgi-keystone.conf \
	&& 	echo "<Location /identity_admin>" >> ~/wsgi-keystone.conf \
	&& 	echo  "SetHandler wsgi-script" >> ~/wsgi-keystone.conf \
	&& 	echo  "Options +ExecCGI" >> ~/wsgi-keystone.conf \
	&& 	echo  "" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIProcessGroup keystone-admin" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIApplicationGroup %{GLOBAL}" >> ~/wsgi-keystone.conf \
	&& 	echo  "WSGIPassAuthorization On" >> ~/wsgi-keystone.conf \
	&& 	echo  "</Location>" >> ~/wsgi-keystone.conf \
	
# Enable the Identity service virtual host
	&&	cp ~/wsgi-keystone.conf . \
	&&	ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled \
	
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		gcc \
		git \
		cmake \
		curl \
		make \
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCE_DIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
VOLUME /etc/keystone
	
EXPOSE 35357 5000

CMD service apache2 start && /usr/bin/mysqld_safe --user=mysql
	
# End of Dockerfile
