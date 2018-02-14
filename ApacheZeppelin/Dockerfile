############## Dockerfile for Apache Zeppelin version 0.7.3 ###############
#
# This Dockerfile builds a basic installation of Apache Zeppelin.
#
# Web-based notebook that enables data-driven,interactive data analytics and collaborative documents with SQL, Scala and more. 
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Zeppelin run the below command:
# docker run --name <container_name> -p <host_port>:8080 -d <image_name>  
# 
# We can view the Apache Zeppelin UI at http://<zeppelin-host-ip>:<port_number>
#
# Reference:
# http://zeppelin.apache.org/docs/0.7.3/index.html
#
#################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
	PATH=$PATH:$JAVA_HOME/bin

# Install dependencies
RUN	apt-get update && apt-get -y install \
		build-essential \
		git \
		maven \
		nodejs \
		openjdk-8-jdk \
		openjdk-8-jdk-headless \
		tar \
		wget \
		
# Install python related packages
		python-dev \
		python-pip \
		gfortran \
		libblas-dev \
		libatlas-dev \
		liblapack-dev \
		libpng-dev \
		libfreetype6-dev \
		libxft-dev \
		python-tk \
		libxml2-dev \
		libxslt-dev \
		zlib1g-dev \
		r-base \
		r-base-dev \
		libcurl4-gnutls-dev \
		libssl-dev \
	&&	pip install numpy \
	&&	pip install matplotlib \
	
# Install R related packages
	&&	R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" \
	&&	Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')" \
	
# Install Yarn
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	wget https://github.com/yarnpkg/yarn/releases/download/v0.24.1/yarn_0.24.1_all.deb \
	&&	dpkg -i yarn_0.24.1_all.deb \
	
# Download source
	&&	git clone https://github.com/apache/zeppelin.git \
	&&	cd zeppelin \
	&&	git checkout v0.7.3 \
	
# Edit $SOURCE_DIR/zeppelin/zeppelin-web/pom.xml
	&&	sed -i '47d' zeppelin-web/pom.xml \
	&&	sed -i '46 a 	<plugin.frontned.version>1.5</plugin.frontned.version> ' zeppelin-web/pom.xml \
	&&	sed -i 's/"json": "bower.json"/"json": "bower.json",/g' zeppelin-web/.bowerrc \
	&&	sed -i '4i "allow_root": true' zeppelin-web/.bowerrc \
	
# Build Apache Zeppelin	
	&&	mvn clean package -DskipTests \
	
# Copy files
	&&	mkdir -p /zeppelin \
	&&	cp -R README.md NOTICE LICENSE bin/ conf/ dev/ docs/ interpreter/ licenses/ notebook/ \
			zeppelin-interpreter/ zeppelin-server/ zeppelin-web/ zeppelin-zengine/ /zeppelin/ \
	&&	chmod 755 /zeppelin/bin/* \
	
# Clean up cache data and remove dependencies which are not required
	&&	rm -rf $HOME/.cache $HOME/.m2 $SOURCE_DIR \
	&&	apt-get -y remove \
		git \
		maven \
		wget \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
EXPOSE 8080

WORKDIR /zeppelin

CMD ["bin/zeppelin.sh", "start"]

# End of Dockerfile
