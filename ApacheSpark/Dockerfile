# © Copyright IBM Corporation 2019, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
##################### Dockerfile for Apache Spark version 3.5.4 ###################################################
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

ARG SPARK_VER=v3.5.4

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheSpark/3.5.4/patch"
ARG JDK11_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%2B9/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.25_9.tar.gz"
ARG JDK8_URL="https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u432-b06_openj9-0.48.0/ibm-semeru-open-jdk_s390x_linux_8u432b06_openj9-0.48.0.tar.gz"

ENV     SOURCE_DIR /root
WORKDIR $SOURCE_DIR

ENV SNAPPY_HOME        $SOURCE_DIR/snappy-1.1.4
ENV LEVELDB_HOME       $SOURCE_DIR/leveldb
ENV LEVELDBJNI_HOME    $SOURCE_DIR/leveldbjni
ENV LIBRARY_PATH       $SNAPPY_HOME
ENV C_INCLUDE_PATH     $LIBRARY_PATH
ENV CPLUS_INCLUDE_PATH $LIBRARY_PATH
ENV LD_LIBRARY_PATH    "${LD_LIBRARY_PATH}:${SOURCE_ROOT}/leveldbjni/META-INF/native/linux64/s390x/"

ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the dependencies
RUN apt-get update -y && apt-get install -y wget tar git libtool autoconf build-essential curl apt-transport-https cmake python3 procps

# Install Java (JDK 8)
RUN mkdir -p /opt/openjdk/8/ \
&& curl -sSL -o jdk8.tar.gz "${JDK8_URL}" \
&& tar -zxf jdk8.tar.gz -C /opt/openjdk/8/ --strip-components 1

# Install Java (JDK 11)
RUN mkdir -p /opt/openjdk/11/ \
&& curl -SL -o jdk11.tar.gz "${JDK11_URL}" \
&& tar -zxf jdk11.tar.gz -C /opt/openjdk/11/ --strip-components 1

# Install Maven
RUN wget -O apache-maven-3.8.8.tar.gz "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz" \
&& tar -zxf apache-maven-3.8.8.tar.gz

# Build Snappy
RUN wget https://github.com/google/snappy/releases/download/1.1.4/snappy-1.1.4.tar.gz \
&& tar -zxvf snappy-1.1.4.tar.gz \
&& cd snappy-1.1.4 \
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
&& JAVA_HOME="/opt/openjdk/8" PATH="/opt/openjdk/8/bin:${SOURCE_DIR}/apache-maven-3.8.8/bin:${PATH}" mvn clean install -P download -Plinux64-s390x -DskipTests \
&& JAVA_HOME="/opt/openjdk/8" PATH="/opt/openjdk/8/bin:${SOURCE_DIR}/apache-maven-3.8.8/bin:${PATH}" jar -xvf ${LEVELDBJNI_HOME}/leveldbjni-linux64-s390x/target/leveldbjni-linux64-s390x-1.8.jar

# Build AirCompressor
RUN git clone -b "0.27" --single-branch https://github.com/airlift/aircompressor.git \
&& cd aircompressor \
&& curl -sSL "${PATCH_URL}/aircompressor.diff" | git apply - \
&& JAVA_HOME="/opt/openjdk/11" PATH="/opt/openjdk/11/bin:${SOURCE_DIR}/apache-maven-3.8.8/bin:${PATH}" mvn install -B -V -DskipTests -Dair.check.skip-all

# Build Apache Spark
RUN git clone -b "${SPARK_VER}" --depth 1  https://github.com/apache/spark.git \
&& cd spark \
&& curl -sSL "${PATCH_URL}/spark.diff" | git apply - \
&& JAVA_HOME="/opt/openjdk/11" PATH="/opt/openjdk/11/bin:${PATH}" ./build/mvn -DskipTests clean package

# Create a tar of the files needed to run spark
RUN mkdir -p dist/spark/lib_override \
&& mv spark/bin dist/spark/bin \
&& mv spark/sbin dist/spark/sbin \
&& mv spark/examples dist/spark/examples \
&& mv spark/data dist/spark/data \
&& mv spark/resource-managers/kubernetes/integration-tests/tests dist/spark/tests \
&& mv spark/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/decom.sh dist/decom.sh \
&& mv leveldbjni/META-INF/native/linux64/s390x/libleveldbjni.so dist/spark/lib_override/libleveldbjni.so \
&& mv spark/assembly/target/scala-2.12/jars dist/spark/jars \
&& tar cf dist.tar dist/

FROM s390x/eclipse-temurin:11-jre-focal

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ARG spark_uid=185

RUN groupadd --system --gid=${spark_uid} spark && \
    useradd --system --uid=${spark_uid} --gid=spark spark

RUN --mount=from=builder,target=/builder \
    set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 procps net-tools gosu libnss-wrapper && \
    mkdir -p /opt && \
    tar -x -o -C /opt --strip-components=1 -f /builder/root/dist.tar && \
    chmod a+x /opt/decom.sh && \
    chown -R spark:spark /opt/spark && \
    chown spark:spark /opt/decom.sh && \
    mkdir -p /opt/spark/work-dir && \
    chmod g+w /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh /opt/

# Set Environment
ENV LD_LIBRARY_PATH "/opt/spark/lib_override/:${LD_LIBRARY_PATH}"
ENV PATH            "/opt/spark/bin:${PATH}"
ENV SPARK_HOME      "/opt/spark"

WORKDIR /opt/spark/work-dir

USER spark

ENTRYPOINT [ "/opt/entrypoint.sh" ]
