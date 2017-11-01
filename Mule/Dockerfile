########## Dockerfile for Mule version 3.8.4 #########
#
# This Dockerfile builds a basic installation of Mule.
#
# Mule is a lightweight integration platform that allows you to connect anything anywhere. Rather than creating point-to-point integrations between systems, services, 
# APIs and devices, you can use Mule to intelligently manage message-routing, data mapping, orchestration, reliability, security and scalability between nodes. 
# Mule applications accept and process messages through several Lego-block-like message processors plugged together in what we call a flow.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start mule server using below command:
# docker run <container_name> -d -p <host-port>:<container-port> -v /<host>:/<container> mule  <commands>
# e.g. docker run --name Mule -d -p 8081:7777 -v /root:/root/ mule_img mule start 
#
# Official website: https://developer.mulesoft.com/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV MULE_HOME=/opt/mule
ENV PATH=$PATH:$JAVA_HOME/bin:$MULE_HOME/bin:$MULE_HOME/conf

WORKDIR $SOURCE_DIR

# Install dependencies
RUN  apt-get update  \
  && apt-get install -y  \
         gcc \
         git \
         make \
         maven \
         openjdk-8-jdk \
         openjdk-8-jre \
         tar \
         unzip \
         wget \

# Download and build source code of Mule
  && cd $SOURCE_DIR/ \
  && git clone https://github.com/linux-on-ibm-z/mule.git \
  && cd $SOURCE_DIR/mule/ \
  && git checkout mule-3.8.4-s390x \
  && cd $SOURCE_DIR/mule/transports/ssl \
  && keytool -selfcert -alias Test -genkey -keystore myStore.keystore -keyalg RSA -validity 1 \
  && cd $SOURCE_DIR/mule/ &&  mvn clean install -Pdistributions -DskipTests -fn \
  && tar -xvf $SOURCE_DIR/mule/distributions/standalone/target/mule-standalone-3.8.4.tar.gz -C $SOURCE_DIR \
  && cp -r $SOURCE_DIR/mule-standalone-3.8.4 /opt/mule \

  && apt-get remove -y \
          gcc \
          git \
          make \
          maven \
          unzip \
          wget \

  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/mule $SOURCE_DIR/target /var/lib/apt/lists/* /root/.m2

VOLUME /data

# Default port mule server
EXPOSE 7777 

# Set the Entrypoint
CMD ["mule"]

# End of Dockerfile
