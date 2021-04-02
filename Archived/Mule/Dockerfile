########## Dockerfile for Mule version 3.9.1 ####################################
#
# This Dockerfile builds a basic installation of Mule.
#
# Mule is a lightweight integration platform that allows you to connect anything anywhere. Rather than creating point-to-point integrations between systems, services,
# APIs and devices, you can use Mule to intelligently manage message-routing, data mapping, orchestration, reliability, security and scalability between nodes.
# Mule applications accept and process messages through several Lego-block-like message processors plugged together in what we call a flow.
#
# To build this image, from the directory containing this Dockerfile :
# (assuming that the file is named Dockerfile)
# docker build -t <image_name> .
#
# Start mule server using below command:
# (assuming that docker image is again commited with copying Java Service Wrapper binary into folder $MULE_HOME/lib/boot/exec)
# docker run --name <container_name> -d -p <host-port>:<container-port> mule  <commands>
# e.g. docker run --name Mule -d -p 8081:7777  mule_img mule start
#
# To provide custom configuration for Mule server use below command:
# docker run --name <container_name> -d -p <port>:7777 -v /host_path/conf:/opt/mule/conf <image-name>
#
# Official website: https://developer.mulesoft.com/
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
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
  && git checkout mule-3.9.1-s390x \
  && cd $SOURCE_DIR/mule/transports/ssl \
  && keytool -selfcert -alias Test -genkey -keystore myStore.keystore -keyalg RSA -validity 1 \
  && cd $SOURCE_DIR/mule/ &&  mvn clean install -Pdistributions -DskipTests -fn \
  && tar -xvf $SOURCE_DIR/mule/distributions/standalone/target/mule-standalone-3.9.1.tar.gz -C $SOURCE_DIR \
  && cp -r $SOURCE_DIR/mule-standalone-3.9.1 /opt/mule \

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
  && rm -rf $SOURCE_DIR/mule $SOURCE_DIR/mule-standalone-3.9.1 $SOURCE_DIR/conf $SOURCE_DIR/target /var/lib/apt/lists/* /root/.m2

# Define mount points.
VOLUME ["/opt/mule/logs", "/opt/mule/conf", "/opt/mule/apps", "/opt/mule/domains"]

# Default port mule, JMX, http port
EXPOSE 7777 1099 8081

# Start mule server
CMD ["mule","console"]

# End of Dockerfile
