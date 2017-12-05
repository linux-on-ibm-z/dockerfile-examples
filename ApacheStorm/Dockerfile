########## Dockerfile for Apache Storm version 1.1.1 #########
#
# This Dockerfile builds a basic installation of Apache Storm.
#
# Apache Storm is a free and open source distributed realtime computation system. Storm is simple, can be used with any programming language.
# Storm makes it easy to reliably process unbounded streams of data, doing for realtime processing what Hadoop did for batch processing.
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start nimbus in seperate shell using below command:
# docker run <container_name> -it -p <container-port> -v /<host>:/<container> storm  <commands>
# e.g. docker run --name Storm -it -p 8080 -v /root:/root/ storm_img storm nimbus 
# 
# Official website: http://storm.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV STORM_HOME=/opt/storm 
ENV _JAVA_OPTIONS=-Xmx4096m
ENV JVM_ARGS="-Xms4096m -Xmx4096m"
ENV MAVEN_OPTS="-Xms4096m -Xmx8192m -Xss4096k"
ENV GPG_TTY=$(tty)
ENV PATH=$JAVA_HOME/bin:$PATH:$STORM_HOME/bin

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \ 
 && apt-get install  -y \
			ant \
			curl \
			git \
			gnupg2 \
			gpgv \
			maven \
			nodejs \
			openjdk-8-jdk \
			python \
			tar \
			wget \
			
# Generate gpg key
 && echo "Key-Type: 1 \n\
    Key-Length: 2048 \n\
    Subkey-Type: 1 \n\
    Subkey-Length: 2048 \n\
    Name-Real: Root Superuser \n\
    Name-Email: root@handbook.westarete.com \n\
    Expire-Date: 0" > gen-key-script \
 && gpg --batch --gen-key gen-key-script \

# Install rvm and nvm
 && ln -sf `which nodejs` /usr/local/bin/node \
 && cd $HOME \			
 && gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
 && curl -L https://get.rvm.io | bash -s stable --autolibs=enabled && . $HOME/.profile \
 && command curl -sSL https://rvm.io/mpapis.asc | gpg --import -  \
 && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash && . $HOME/.bashrc \
  
# Download and build source code of Apache Storm
 && cd $SOURCE_DIR \
 && git clone https://github.com/apache/storm.git \
 && cd storm/ \
 && git checkout tags/v1.1.1 \
 && mvn clean install -DskipTests \
  
# Create binary distribution
 && cd storm-dist/binary && mvn package \
 && tar -zxf $SOURCE_DIR/storm/storm-dist/binary/target/apache-storm-1.1.1.tar.gz -C $SOURCE_DIR/ \
 && cp -r $SOURCE_DIR/apache-storm-1.1.1 /opt/storm \
 
  
# Clean up the unwanted packages and clear the source directory 
 && apt-get remove -y \
			ant \
			curl \
			git \
			gnupg2 \
			maven \
			wget \
			       
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* $SOURCE_DIR/storm /root/.m2 

VOLUME /data

# Port for Apache Storm
EXPOSE 6700 6701 6702 6703 8080 2181 6627 8080 8000	3772 3773 3774	

# Set Entrypoint
CMD ["storm"]
 
# End of Dockerfile
