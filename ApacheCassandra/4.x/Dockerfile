# Copyright IBM Corporation 2025, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Cassandra version 4.1.10 #########
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

FROM debian:bookworm-slim as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ARG CASSANDRA_VER=4.1.10

ENV SOURCE_ROOT=/tmp/source \
    CASSANDRA_USE_JDK11=true

# Set JAVA_HOME
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy Java 11 from Temurin for build stage
COPY --from=eclipse-temurin:11-jdk $JAVA_HOME $JAVA_HOME

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
wget \
curl \
sudo \
ant \
ant-optional \
junit \
git \
tar \
g++ \
make  \
automake \
autoconf \
libtool \
patch \
libx11-dev \
libxt-dev \
pkg-config \
texinfo \
locales-all \
unzip \
python3-dev \
maven \
# Build netty-tcnative
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheCassandra/$CASSANDRA_VER/patch/build_netty.sh  \
    && bash build_netty.sh -y -j Temurin11 \
# Build netty
    && cd $SOURCE_ROOT \
    && git clone -b netty-4.1.58.Final https://github.com/netty/netty.git \
    && cd netty\
    && curl -o netty.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheCassandra/$CASSANDRA_VER/patch/netty.patch \
    && git apply --ignore-whitespace netty.patch \
    && mvn install -DskipTests -Dmaven.javadoc.skip=true \
# Build Chronicle-core
    && cd $SOURCE_ROOT \
    && git clone -b chronicle-bytes-2.20.111 https://github.com/OpenHFT/Chronicle-Bytes \
    && cd Chronicle-Bytes \
    && curl -o bytes.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheCassandra/$CASSANDRA_VER/patch/bytes.patch \
    && git apply --ignore-whitespace bytes.patch \
    && mvn install -DskipTests -Dmaven.javadoc.skip=true \
# Build Apache Cassandra
    && cd $SOURCE_ROOT \
    && git clone -b cassandra-$CASSANDRA_VER https://github.com/apache/cassandra.git \
    && cd cassandra \
    && curl -o cassandra.patch https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheCassandra/$CASSANDRA_VER/patch/cassandra.patch \
    && git apply --ignore-whitespace cassandra.patch \
    && ant \
# Copy required libs
    && mkdir -p /cassandra_libs \
    && cp -r $SOURCE_ROOT/cassandra /cassandra_libs \
    && cp -r $SOURCE_ROOT/netty-tcnative/boringssl-static/target/native-jar-work/META-INF/native/libnetty_tcnative_linux_s390_64.so /cassandra_libs \
    && cp -r $SOURCE_ROOT/netty/transport-native-epoll/target/classes/META-INF/native/libnetty_transport_native_epoll_s390_64.so /cassandra_libs \
# Cleanup
    && apt-get -y remove \
    git \
    unzip \
    wget \
    && apt-get autoremove -y \
    && apt autoremove -y \
    && rm -rf $SOURCE_ROOT \
    && rm -rf /root/.cache/ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#End of builder stage    

FROM debian:bookworm-slim

# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r cassandra --gid=999; \
	useradd -r -g cassandra --uid=999 cassandra

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# solves warning: "jemalloc shared library could not be preloaded to speed up memory allocations"
		libjemalloc2 \
# "free" is used by cassandra-env.sh
		procps \
# "cqlsh" needs a python interpreter
		python3 \
# "ip" is not required by Cassandra itself, but is commonly used in scripting Cassandra's configuration (since it is so fixated on explicit IP addresses)
		iproute2 \
# Cassandra will automatically use numactl if available
#   https://github.com/apache/cassandra/blob/18bcda2d4c2eba7370a0b21f33eed37cb730bbb3/bin/cassandra#L90-L100
#   https://github.com/apache/cassandra/commit/604c0e87dc67fa65f6904ef9a98a029c9f2f865a
		numactl \
	; \
	rm -rf /var/lib/apt/lists/*; \
# https://issues.apache.org/jira/browse/CASSANDRA-15767 ("bin/cassandra" only looks for "libjemalloc.so" or "libjemalloc.so.1" which doesn't match our "libjemalloc.so.2")
	libjemalloc="$(readlink -e /usr/lib/*/libjemalloc.so.2)"; \
	ln -sT "$libjemalloc" /usr/local/lib/libjemalloc.so; \
	ldconfig

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.19
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates dirmngr gnupg wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

ENV JAVA_HOME /opt/java/openjdk
COPY --from=eclipse-temurin:11-jre $JAVA_HOME $JAVA_HOME
ENV PATH $JAVA_HOME/bin:$PATH
RUN java --version

ENV CASSANDRA_HOME /opt/cassandra
ENV CASSANDRA_CONF /etc/cassandra
ENV PATH $CASSANDRA_HOME/bin:$PATH
ENV CASSANDRA_VERSION 4.1.10


RUN mkdir -p "$CASSANDRA_HOME";

# COPY the required libs, binaries from builder stage
COPY --from=builder /cassandra_libs/cassandra/bin $CASSANDRA_HOME/bin
COPY --from=builder /cassandra_libs/cassandra/conf $CASSANDRA_HOME/conf
COPY --from=builder /cassandra_libs/cassandra/doc $CASSANDRA_HOME/doc
COPY --from=builder /cassandra_libs/cassandra/lib $CASSANDRA_HOME/lib
COPY --from=builder /cassandra_libs/cassandra/pylib $CASSANDRA_HOME/pylib
COPY --from=builder /cassandra_libs/cassandra/tools $CASSANDRA_HOME/tools
COPY --from=builder /cassandra_libs/cassandra/build $CASSANDRA_HOME/build
COPY --from=builder /cassandra_libs/cassandra/*.txt $CASSANDRA_HOME/
COPY --from=builder /cassandra_libs/libnetty_tcnative_linux_s390_64.so  /usr/lib/
COPY --from=builder /cassandra_libs/libnetty_transport_native_epoll_s390_64.so  /usr/lib/	

RUN	[ ! -e "$CASSANDRA_CONF" ]; \
	mv "$CASSANDRA_HOME/conf" "$CASSANDRA_CONF"; \
	ln -sT "$CASSANDRA_CONF" "$CASSANDRA_HOME/conf"; \
	\
	mkdir -p "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra; \
	chown -R cassandra:cassandra "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra; \
	chmod 777 "$CASSANDRA_CONF" /var/lib/cassandra /var/log/cassandra; \
	chmod -R a+rwX "$CASSANDRA_CONF"; \
	ln -sT /var/lib/cassandra "$CASSANDRA_HOME/data"; \
	ln -sT /var/log/cassandra "$CASSANDRA_HOME/logs"; \
	\
# smoke test
	cassandra -v

VOLUME /var/lib/cassandra

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
CMD ["cassandra", "-f"]
