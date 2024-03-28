# © Copyright IBM Corporation 2019, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
##################### Dockerfile for Apache Spark version 3.5.0 ###################################################
#
# This Dockerfile builds a basic installation of Apache Spark.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Spark through the Scala shell:
# docker run --name <container name> -it <image_name> /opt/spark/bin/spark-shell
#
##################################################################################################################
# Base Image
FROM s390x/ubuntu:22.04 AS builder

ARG SPARK_VER=v3.5.0

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheSpark/3.5.0/patch/spark.diff"
ARG JDK11_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.19%2B7/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.19_7.tar.gz"
ARG JDK8_URL="https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u372-b07_openj9-0.38.0/ibm-semeru-open-jdk_s390x_linux_8u372b07_openj9-0.38.0.tar.gz"

ENV     SOURCE_DIR /root
WORKDIR $SOURCE_DIR

# Java download URLs

ENV SNAPPY_HOME        $SOURCE_DIR/snappy-1.1.3
ENV LEVELDB_HOME       $SOURCE_DIR/leveldb
ENV LEVELDBJNI_HOME    $SOURCE_DIR/leveldbjni
ENV LIBRARY_PATH       $SNAPPY_HOME
ENV C_INCLUDE_PATH     $LIBRARY_PATH
ENV CPLUS_INCLUDE_PATH $LIBRARY_PATH
ENV LD_LIBRARY_PATH    "${LD_LIBRARY_PATH}:${SOURCE_ROOT}/leveldbjni/META-INF/native/linux64/s390x/"
ENV MAVEN_OPTS         "-Xss128m -Xmx3g -XX:ReservedCodeCacheSize=1g"
ENV PATH               "${PATH}:${SOURCE_DIR}/apache-maven-3.8.8/bin"

ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the dependencies
RUN apt-get update -y && apt-get install -y wget tar gzip git libtool autoconf build-essential curl apt-transport-https

# Install Java (JDK 8)
RUN mkdir -p /opt/openjdk/8/ \
&& curl -SL -o jdk8.tar.gz "${JDK8_URL}" \
&& tar -zxf jdk8.tar.gz -C /opt/openjdk/8/ --strip-components 1

# Install Java (JDK 11)
RUN mkdir -p /opt/openjdk/11/ \
&& curl -SL -o jdk11.tar.gz "${JDK11_URL}" \
&& tar -zxf jdk11.tar.gz -C /opt/openjdk/11/ --strip-components 1

# Install Maven
RUN wget -O apache-maven-3.8.8.tar.gz "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz" \
&& tar -zxf apache-maven-3.8.8.tar.gz

# Build Snappy
RUN wget https://github.com/google/snappy/releases/download/1.1.3/snappy-1.1.3.tar.gz \
&& tar -zxvf snappy-1.1.3.tar.gz \
&& cd snappy-1.1.3 \
&& ./configure --disable-shared --with-pic \
&& make \
&& make install

# Build LevelDB JNI
RUN git clone -b s390x https://github.com/linux-on-ibm-z/leveldb.git \
&& git clone -b leveldbjni-1.8-s390x https://github.com/linux-on-ibm-z/leveldbjni.git \
&& cd ${LEVELDB_HOME} \
&& git apply ${LEVELDBJNI_HOME}/leveldb.patch \
&& make libleveldb.a \
&& cd ${LEVELDBJNI_HOME} \
&& JAVA_HOME="/opt/openjdk/8/" PATH="/opt/openjdk/8/bin/:${PATH}" mvn clean install -P download -Plinux64-s390x -DskipTests \
&& JAVA_HOME="/opt/openjdk/8/" PATH="/opt/openjdk/8/bin/:${PATH}" jar -xvf ${LEVELDBJNI_HOME}/leveldbjni-linux64-s390x/target/leveldbjni-linux64-s390x-1.8.jar

# Build Apache Spark
RUN git clone -b "${SPARK_VER}" https://github.com/apache/spark.git --depth 1 \
&& cd spark \
&& curl -sSL "${PATCH_URL}" | git apply \
&& JAVA_HOME="/opt/openjdk/11/" PATH="/opt/openjdk/11/bin/:${PATH}" ./build/mvn -DskipTests clean package

FROM s390x/ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG SPARK_SCALA_VERSION=2.12
ARG spark_uid=185

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 procps net-tools && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/examples && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/openjdk/11/     /opt/openjdk/11/
COPY --from=builder /root/spark/bin      /opt/spark/bin
COPY --from=builder /root/spark/sbin     /opt/spark/sbin
COPY --from=builder /root/spark/examples /opt/spark/examples
COPY --from=builder /root/spark/data     /opt/spark/data
COPY --from=builder /root/spark/resource-managers/kubernetes/integration-tests/tests     /opt/spark/tests

# Copy native shared objects and jars
COPY --from=builder /root/leveldbjni/META-INF/native/linux64/s390x/libleveldbjni.so /opt/spark/lib_override/libleveldbjni.so
COPY --from=builder /root/spark/assembly/target/scala-$SPARK_SCALA_VERSION/jars /opt/spark/jars

COPY entrypoint.sh /opt/
COPY decom.sh /opt/

# Set Environment
ENV LD_LIBRARY_PATH "/opt/spark/lib_override/:${LD_LIBRARY_PATH}"
ENV JAVA_HOME       "/opt/openjdk/11/"
ENV PATH            "${JAVA_HOME}/bin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME      "/opt/spark"

WORKDIR /opt/spark/work-dir
RUN chmod g+w /opt/spark/work-dir
RUN chmod a+x /opt/entrypoint.sh
RUN chmod a+x /opt/decom.sh

# Run Spark
ENTRYPOINT [ "/opt/entrypoint.sh" ]

USER ${spark_uid}
