# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for Apache Zeppelin version 0.8.0 ###############
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
# http://zeppelin.apache.org/docs/0.8.0/index.html
#
#################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
	PATH=$PATH:$JAVA_HOME/bin \
	QT_QPA_PLATFORM=offscreen \
	LD_LIBRARY_PATH=/usr/local/lib
	
WORKDIR $SOURCE_DIR

# Install dependencies
RUN	apt-get update && apt-get -y install \
		autoconf \
		automake \
		build-essential \
		bzip2 \
		curl \
		g++ \
		git \
   		libtool \
   	 	make \
   	 	maven \
		openjdk-8-jdk \
		openjdk-8-jdk-headless \
		phantomjs \
   	 	tar \
   	 	unzip \
	    wget \
	    
# Install python related packages (Optional)
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
	
# Install R related packages (Optional)
	&&	R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" \
	&&	R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" \
	&&	Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')" \	    
	
# Download and install Protobuf 3.3.0
	&&  cd $SOURCE_DIR \	
	&&  git clone git://github.com/google/protobuf.git \
 	&&  cd protobuf \
	&&  git checkout v3.3.0 \
	&&  git config --global url."git://github.com/".insteadOf "https://github.com/" \
 	&&  git submodule update --init --recursive \
 	
 	&&  ./autogen.sh \
 	&&  ./configure \
 	&&  make && make install && ldconfig \

# Download and install gRPC-Java 1.4.0	
	&&  cd $SOURCE_DIR \
	&&  git clone https://github.com/grpc/grpc-java.git \
	&&  cd grpc-java \
	&&  git checkout v1.4.0 \
	&&  sed -i '52i gcc(Gcc) { target("s390_64") }' compiler/build.gradle \ 
	&&  sed -i '67i s390_64 { architecture "s390_64" }' compiler/build.gradle \
	&&  sed -i '72d' compiler/build.gradle \
	&&  sed -i "72i if (arch in ['x86_32', 'x86_64', 'ppcle_64', 's390_64']) {" compiler/build.gradle \
	&&  ./gradlew install -Pprotoc=/usr/local/bin/protoc \
	
# Download zeppelin source
	&&  cd $SOURCE_DIR \
	&&	git clone https://github.com/apache/zeppelin.git \
	&&	cd zeppelin \
	&&	git checkout v0.8.0 \
	
# Edit $SOURCE_DIR/zeppelin/zeppelin-web/.bowerrc and pom.xml
 	&&	sed -i 's/"json": "bower.json"/"json": "bower.json",/g' zeppelin-web/.bowerrc \
  	&&	sed -i '4i "allow_root": true' zeppelin-web/.bowerrc \
 	&&  sed -i -e 's/install --no-lockfile/install --no-lockfile --unsafe-perm/g' zeppelin-web/pom.xml \
	
# Edit $SOURCE_DIR/zeppelin/pom.xml
    &&  sed -i '98d' pom.xml \
    && 	sed -i '97a <plugin.frontend.version>1.5</plugin.frontend.version>' pom.xml \
	
# Build Apache Zeppelin	
 	&&  mvn install:install-file -DgroupId=com.google.protobuf -DartifactId=protoc -Dversion=3.3.0 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/protobuf/src/.libs/protoc \
 	&&  mvn install:install-file -DgroupId=io.grpc -DartifactId=protoc-gen-grpc-java -Dversion=1.4.0 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/grpc-java/compiler/build/exe/java_plugin/protoc-gen-grpc-java \
	&&	mvn clean package -DskipTests \
	
# Copy files
	&&	mkdir -p /zeppelin \
	&&	cp -R README.md NOTICE LICENSE bin/ conf/ dev/ docs/ interpreter/ licenses/ notebook/ \
			zeppelin-interpreter/ zeppelin-server/ zeppelin-web/ zeppelin-zengine/ /zeppelin/ \
	&&	chmod 755 /zeppelin/bin/* \
	
# Clean up cache data and remove dependencies which are not required
	&&	rm -rf $HOME/.cache $HOME/.m2 $SOURCE_DIR \
	&&	apt-get -y remove \
		autoconf \
		automake \
		bzip2 \
		curl \
		g++ \
		git \
	    libtool \
	    make \
	    maven \
 	    unzip \
	    wget \	
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*
	
EXPOSE 8080

WORKDIR /zeppelin

CMD ["bin/zeppelin.sh", "start"]

# End of Dockerfile
