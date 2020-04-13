# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############## Dockerfile for Apache Zeppelin version 0.8.1 ###############
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
# http://zeppelin.apache.org/docs/0.8.1/index.html
#
#################################################################################

# Base Image
FROM s390x/ubuntu:18.04 AS builder

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ARG ZEPPELIN_VER=0.8.1

ENV SOURCE_DIR=/tmp/source MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
	PATH=$PATH:$JAVA_HOME/bin \
	QT_QPA_PLATFORM=offscreen \
	LD_LIBRARY_PATH=/usr/local/lib
	
WORKDIR $SOURCE_DIR

# Install dependencies
RUN     apt-get update && apt-get -y install \
                build-essential \
                git \
                tar \
                wget \
                maven \
                openjdk-8-jdk-headless \
                openjdk-8-jdk \
                patch \
                python \
                phantomjs \
                autoconf \
                libtool \
                automake \
                g++ \
                make \
                git \
                bzip2 \
                curl \
                unzip \
                zlib1g-dev \
	
# Download and install Protobuf 3.3.0
	&&  cd $SOURCE_DIR \	
	&&  git clone git://github.com/google/protobuf.git \
 	&&  cd protobuf \
	&&  git checkout v3.3.0 \
	&&  git config --global url."git://github.com/".insteadOf "https://github.com/" \
 	&&  git submodule update --init --recursive \
 	&&  ./autogen.sh \
 	&&  ./configure \
 	&&  make && make install && ldconfig

# Download and install gRPC-Java 1.4.0	
RUN	cd $SOURCE_DIR \
	&&  git clone https://github.com/grpc/grpc-java.git \
	&&  cd grpc-java \
	&&  git checkout v1.4.0 \
        &&  curl -o build_gradle.diff https://d905717b35db10e187ae62ca31080d42c0a735b4@raw.github.ibm.com/loz/ApacheZeppelin/master/build_gradle.diff \
        &&  patch --ignore-whitespace ./compiler/build.gradle < build_gradle.diff \
	&&  ./gradlew install -Pprotoc=/usr/local/bin/protoc 
	
# Download zeppelin source
RUN  cd $SOURCE_DIR \
	&&	git clone https://github.com/apache/zeppelin.git \
	&&	cd zeppelin \
	&&	git checkout v${ZEPPELIN_VER} \
	&&	curl -o zeppline.diff https://d905717b35db10e187ae62ca31080d42c0a735b4@raw.github.ibm.com/loz/ApacheZeppelin/master/zeppline.diff \
	&&	git apply zeppline.diff \

# Build Apache Zeppelin	
 	&&  mvn install:install-file -DgroupId=com.google.protobuf -DartifactId=protoc -Dversion=3.3.0 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/protobuf/src/.libs/protoc \
 	&&  mvn install:install-file -DgroupId=io.grpc -DartifactId=protoc-gen-grpc-java -Dversion=1.4.0 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/grpc-java/compiler/build/exe/java_plugin/protoc-gen-grpc-java \
	&& mvn clean package -Pbuild-distr -DskipTests

FROM s390x/ubuntu:16.04

RUN apt-get update -y

WORKDIR /root

COPY  --from=builder /tmp/source/zeppelin/zeppelin-distribution/target/zeppelin-0.8.1.tar.gz /root

ARG ZEPPELIN_VER=0.8.1

ENV SOURCE_DIR=/root MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" \
        JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x \
        PATH=$PATH:$JAVA_HOME/bin \
        QT_QPA_PLATFORM=offscreen \
        LD_LIBRARY_PATH=/usr/local/lib \
        Z_HOME="/zeppelin"

WORKDIR /root

# Install dependencies
RUN     apt-get update && apt-get -y install \
                build-essential \
                openjdk-8-jdk \
                openjdk-8-jdk-headless \
                phantomjs \
                tar \
                unzip \
                wget \
                python-dev \
                python-pip \
                gfortran \
                libblas-dev \
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
        &&      pip install --upgrade pip \
        &&      python -m pip install numpy \
        &&      python -m pip install matplotlib \

# Extract zeppline
        &&      tar -zxvf zeppelin-0.8.1.tar.gz \
        &&      rm -rf zeppelin-0.8.1.tar.gz \
        &&      mkdir -p ${Z_HOME} && mv `pwd`/zeppelin-0.8.1/* ${Z_HOME}  \
        &&      chown -R root:root ${Z_HOME} \
        &&      mkdir -p ${Z_HOME}/logs ${Z_HOME}/run ${Z_HOME}/webapps \
# Allow process to edit /etc/passwd, to create a user entry for zeppelin
        &&      chgrp root /etc/passwd && chmod ug+rw /etc/passwd  \
# Give access to some specific folders
        &&      chmod -R 775 "${Z_HOME}/logs" "${Z_HOME}/run" "${Z_HOME}/notebook" "${Z_HOME}/conf" \
# Allow process to create new folders (e.g. webapps)
        &&      chmod 775 ${Z_HOME} \

# Clean up cache data and remove dependencies which are not required
        &&      rm -rf $HOME/.cache $HOME/.m2 $SOURCE_DIR \
        &&      apt-get -y remove \
            unzip \
            wget \
        &&      apt-get autoremove -y \
        &&      apt autoremove -y \
        &&      apt-get clean \
        &&      rm -rf /var/lib/apt/lists/*

EXPOSE 8080

WORKDIR /zeppelin

CMD ["bin/zeppelin.sh", "start"]
