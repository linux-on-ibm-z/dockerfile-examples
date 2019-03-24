########## Linux on z Systems Dockerfile for Cassandra version 3.11.4 #########
#
# This Dockerfile builds a basic installation of Cassandra.
#
# Apache Cassandra is an open source distributed database management system designed
# to handle large amounts of data across many commodity servers, providing high
# availability with no single point of failure
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Cassandra Server create a container from the image created from Dockerfile
# docker run --name <container_name> -p <port_number>:7000 -p <port_number>:7001 -p <port_number>:7199 -p <port_number>:9042 -p <port_number>:9160 -d <image_name>
#
#################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/root
WORKDIR $SOURCE_DIR
ENV ANT_HOME=$SOURCE_DIR/apache-ant-1.9.4
RUN unset JAVA_TOOL_OPTIONS
ENV LANG="en_US.UTF-8"
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
ENV ANT_OPTS="-Xms4G -Xmx4G"
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV PATH=$PATH:$ANT_HOME/bin:$JAVA_HOME/bin

RUN groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra

RUN apt-get update && apt-get install -y \
    automake \
    autoconf\
    git \
    g++ \
    libx11-dev \
    libxt-dev  \
    libtool \
    locales-all \
    make  \
    openjdk-8-jre \
    openjdk-8-jdk  \
    patch  \
    pkg-config \
    python \
    texinfo \
    tar \
    wget \
    unzip     \
	
# Install Apache Ant and Jna
&& cd $SOURCE_DIR \
&& wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz \
&& tar -xvf apache-ant-1.9.4-bin.tar.gz \
&& git clone https://github.com/java-native-access/jna.git \
&& cd jna \
&& git checkout 4.2.2 \
&& ant \

# Build and install Apache Cassandra 3.11.4
&& cd $SOURCE_DIR \
&& git clone https://github.com/apache/cassandra.git \
&& cd cassandra \
&& git checkout cassandra-3.11.4 \
&& sed  -i ' s/Xss256k/Xss32m/' build.xml conf/jvm.options \
&& sed  -i ' s/-XX:+UseNUMA//' conf/jvm.options \
&& sed  -i ' s/JVM_OPTS="$JVM_OPTS -XX:+UseCondCardMark"//' conf/jvm.options \
&& touch ant.log \
&& nohup ant 2<&1 | tee ant.log \
&& wget http://downloads.jboss.org/byteman/3.0.3/byteman-download-3.0.3-bin.zip \
&& unzip byteman-download-3.0.3-bin.zip -d /tmp \
&& rm  -f  build/lib/jars/byteman-install-3.0.3.jar \
&& cp  /tmp/byteman-download-3.0.3/lib/byteman-install.jar ./build/lib/jars/byteman-install-3.0.3.jar \
&& ant \
&& rm -rf lib/jna-4.0.0.jar \
&& cp $SOURCE_DIR/jna/build/jna.jar $SOURCE_DIR/cassandra/lib/jna.jar \
&& cp -R $SOURCE_DIR/cassandra /usr/share/ \
&& rm -rf /root/apache-ant-1.9.4 /root/apache-ant-1.9.4-bin.tar.gz /root/jna /root/cassandra \
&& rm -rf /usr/share/cassandra/test /usr/share/cassandra/byteman-download-3.0.3-bin.zip \

# Clean up source dir and unused packages/libraries
&& apt-get remove -y \
    automake \
    autoconf\
    make  \
    patch  \
    pkg-config \
    wget \
    unzip     \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& chown -R cassandra:cassandra /usr/share/cassandra  \
&& chmod -R 777 /usr/share/cassandra

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& { command -v gpgconf && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh 
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

VOLUME [ "/usr/share/cassandra/data/" ]

# Set Path
ENV PATH $PATH:/usr/share/cassandra/bin
ENV CASSANDRA_CONFIG /usr/share/cassandra/conf

# Expose Ports
EXPOSE 7000 7001 7199 9042 9160

# Start Cassandra server
CMD ["cassandra", "-f"]
