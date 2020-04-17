# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
########## Dockerfile for Alfresco version 5.2 #####################
#
# This Dockerfile builds a basic installation of Alfresco.
#
# Alfresco is a collection of information management software products Unix-like operating systems developed using Java technology. 
# Their primary software offering, branded as a Digital Business Platform is proprietary & a commercially licensed open source platform, 
# supports open standards, and provides enterprise scale.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Alfresco run the below command:
# docker run --name <container_name> -p <host_port>:8080 -d <image_name>  
#
# We can view the Alfresco UI at http://<Alfresco-host-ip>:<port_number>/alfresco
# 
# Reference:
# https://www.alfresco.com/
#
##################################################################################
#
#	NOTE:- Kindly check correct pg_hba.conf file for PostgreSQL before editing.
#
##################################################################################
# Base Image
FROM s390x/ubuntu:16.04
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV	SOURCE_DIR=/tmp/source 
ENV	JAVA_DIR=/tmp/java
ENV	M2_HOME=$SOURCE_DIR/apache-maven-3.3.9 
ENV	JAVA_HOME=$JAVA_DIR/jdk8u181-b13 
ENV	PATH=$M2_HOME/bin:$JAVA_HOME/bin:$PATH 
ENV	MAVEN_OPTS="-Xmx1024m" 
ENV	_JAVA_OPTIONS=-Xmx10g
# Install dependencies
RUN	apt-get update && apt-get -y install \
		ant \
		curl \
		gcc \
		git \
		make \
		postgresql \
		postgresql-contrib \
		subversion \
		tar \
		wget \
# Configure PostgreSQL Database
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	sed -i '85s/postgres/all/' /etc/postgresql/9.5/main/pg_hba.conf \
	&&	sed -i '85s/peer/trust/' /etc/postgresql/9.5/main/pg_hba.conf \
	&&	service postgresql start \
	&&	sleep 30s \
	&&	psql -U postgres -c "CREATE USER alfresco WITH PASSWORD 'alfresco';" \
	&&	psql -U postgres -c "CREATE DATABASE alfresco;" \
	&&	psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE alfresco to alfresco;" \
	&&	service postgresql restart \
# Install AdoptOpenJDK v8u181b13
	&&	mkdir -p $JAVA_DIR \
	&&	cd $JAVA_DIR \
	&&	curl -SLO https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u181-b13/OpenJDK8U-jdk_s390x_linux_hotspot_8u181b13.tar.gz \
	&&	tar -xvzf OpenJDK8U-jdk_s390x_linux_hotspot_8u181b13.tar.gz \
	&&	cp /usr/lib/jvm/default-java/jre/lib/security/cacerts $JAVA_HOME/jre/lib/security/ \
# Install OpenSSL version 1.0.2k
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/openssl/openssl.git \
	&&	cd openssl \
	&&	git checkout OpenSSL_1_0_2k \
	&&	./config --prefix=/usr --openssldir=/usr/local/openssl shared \
	&&	make \
	&&	make install \
# Build and Install Apache Tomcat
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/apache/tomcat.git \
	&&	cd tomcat/ \
	&&	git checkout 8.5.32 \
	&&	cp build.properties.default build.properties \
	&&	ant \
# Configure Tomcat
	&&	groupadd tomcat \
	&&	useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat \
	&&	mkdir /opt/tomcat \
	&&	cp -R $SOURCE_DIR/tomcat/output/build/* /opt/tomcat/ \
	&&	cd /opt/tomcat \
	&&	chgrp -R tomcat /opt/tomcat \
	&&	chmod -R g+r conf \
	&&	chmod g+x conf \
	&&	chown -R tomcat webapps/ temp/ logs/ \
	&&	sed -i '44i <role rolename="manager-gui"/>' conf/tomcat-users.xml \
	&&	sed -i '45i <role rolename="manager-script"/>' conf/tomcat-users.xml \
	&&	sed -i '46i <user username="admin" password="admin" roles="manager-gui, manager-script"/>' conf/tomcat-users.xml \
	&&	cd lib \
	&&	curl -SLO https://jdbc.postgresql.org/download/postgresql-42.1.4.jar \
# Install Maven
	&&	cd $SOURCE_DIR \
	&&	curl -SLO https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
	&&	tar -xvzf apache-maven-3.3.9-bin.tar.gz \
# Get Alfresco Source code
	&&	svn co https://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/COMMUNITYTAGS/5.2.g/ \
# Remove or comment on the line 31 of the file: ./5.2.g/root/projects/solr4/source/java/org/alfresco/solr/AlfrescoSolrCloseHook.java
	&&	sed -i '31 s/^/\/\//' ./5.2.g/root/projects/solr4/source/java/org/alfresco/solr/AlfrescoSolrCloseHook.java \
# Change alfresco-global.properties.sample to alfresco-global.properties
	&&	mv 5.2.g/root/projects/repository/config/alfresco-global.properties.sample 5.2.g/root/projects/repository/config/alfresco-global.properties \
# Edit 5.2.g/root/projects/repository/config/alfresco-global.properties file
	&&	sed -i '11i dir.root=/Alfresco/alf_data' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '12i dir.contentstore=/Alfresco/alf_data/contentstore' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '13i dir.contentstore.deleted=/Alfresco/alf_data/contentstore.deleted' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '14i db.name=alfresco' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '15i db.username=alfresco' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '16i db.password=alfresco' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '17i db.host=localhost' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '18i db.port=5432' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '19i db.url=jdbc:postgresql://localhost:5432/alfresco' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '20i db.pool.max=275' 5.2.g/root/projects/repository/config/alfresco-global.properties \
	&&	sed -i '21i db.driver=org.postgresql.Driver' 5.2.g/root/projects/repository/config/alfresco-global.properties \
# Edit 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties file
	&&	sed -i '8d;9d;10d;11d;12d;13d' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '4i dir.root=/Alfresco/alf_data' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '5i dir.contentstore=/Alfresco/alf_data/contentstore' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '6i dir.contentstore.deleted=/Alfresco/alf_data/contentstore.deleted' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '11i db.host=localhost' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '12i db.port=5432' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '13i db.url=jdbc:postgresql://localhost:5432/alfresco' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
	&&	sed -i '14i db.pool.max=275' 5.2.g/root/projects/dev-tomcat/src/main/tomcat/shared/classes/alfresco-global.properties \
# Build and Install Alfresco
	&&	cd 5.2.g/root/ \
	&&	mvn clean install -DskipTests \
# Copy alfresco.war to /opt/tomcat/webapps
	&&	cd /opt/tomcat \
	&&	cp $SOURCE_DIR/5.2.g/root/projects/web-client/target/alfresco.war webapps/ \
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		ant \
		curl \
		gcc \
		git \
		make \
		subversion \
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&&	rm -rf $HOME/.m2 \
	&&	rm -rf $SOURCE_DIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
EXPOSE 8080
WORKDIR /opt/tomcat
CMD service postgresql restart && bin/catalina.sh run
# End of Dockerfile
