# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Antlr4-4.8 ################################
#
# Builds ANTRL and the following supported runtime libraries:
# Java, Python, Go, NodeJS and C++.
#
# To build this image, from the directory containing this Dockerfile:
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container_name> -it <image_name> /bin/bash
#
###############################################################################

# Base image
FROM s390x/ubuntu:18.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

# Environment
ENV SOURCE_ROOT=/tmp

WORKDIR /tmp
COPY antlr4-8.patch .

RUN apt-get update \
&&  apt-get install -y \
      tar unzip xz-utils uuid-dev curl wget git make patch \
      python python3 golang gcc g++ cmake \
### Install Java ##########################################
&&  cd $SOURCE_ROOT \
&&  TARBALL=OpenJDK11U-jdk_s390x_linux_openj9_11.0.6_10_openj9-0.18.1.tar.gz \
&&  URL="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download" \
&&  curl -s -S -L -O "${URL}/jdk-11.0.6%2B10_openj9-0.18.1/${TARBALL}" \
&&  tar -zxf ${TARBALL} \
&&  JAVA_HOME=$SOURCE_ROOT/jdk-11.0.6+10 \
&&  export JAVA_HOME \
&&  PATH=$JAVA_HOME/bin:$PATH \
### Install Node ##########################################
&&  TARBALL=node-v12.14.1-linux-s390x.tar.xz \
&&  curl -s -S -L -O "https://nodejs.org/dist/v12.14.1/${TARBALL}" \
&&  tar xJf ${TARBALL} \
&&  PATH=$SOURCE_ROOT/node-v12.14.1-linux-s390x/bin:$PATH \
### Install Antlr #########################################
&&  ZIP=antlr4-4.8.zip \
&&  URL="https://github.com/antlr/antlr4/archive/4.8.zip" \
&&  curl -s -S -L -o ${ZIP} "${URL}" \
&&  unzip ${ZIP} \
### Install Maven #########################################
&&  TARBALL=apache-maven-3.3.9-bin.tar.gz \
&&  URL="https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries" \
&&  curl -s -S -L -O "${URL}/${TARBALL}" \
&&  tar xzf ${TARBALL} \
&&  PATH=$SOURCE_ROOT/apache-maven-3.3.9/bin:$PATH \
### Build Antrl ###########################################
&&  MAVEN_OPTS="-Xmx1G" \
&&  CC=gcc \
&&  CXX=g++ \
&&  export MAVEN_OPTS CC CXX \
&&  cd $SOURCE_ROOT/antlr4-4.8 \
&&  patch -p1 < /tmp/antlr4-8.patch \
&&  mvn install -DskipTests=true \
&&  cd runtime/Cpp \
&&  mkdir build && mkdir run \
&&  cd build \
&&  cmake -DWITH_LIBCXX=Off -DCMAKE_BUILD_TYPE=release .. \
&&  make -j 8 \
&&  DESTDIR=$SOURCE_ROOT/antlr4-4.8/runtime/Cpp/run make install \
### Tidy and clean up ###########################################
&& rm -rf $SOURCE_DIR/OpenJDK11U-jdk_s390x_linux_openj9_11.0.6_10_openj9-0.18.1.tar.gz  \
&& rm -rf $SOURCE_DIR/node-v12.14.1-linux-s390x.tar.xz  \
&& rm -rf $SOURCE_DIR/apache-maven-3.3.9-bin.tar.gz  \
&& rm -rf $SOURCE_DIR/antlr4-4.8.zip 
# Multistage build
FROM s390x/ubuntu:18.04
# Environment
ENV SOURCE_ROOT=/tmp
WORKDIR /tmp
COPY --from=builder $SOURCE_ROOT/antlr4-4.8 $SOURCE_ROOT/antlr4-4.8
COPY --from=builder /root/.m2/repository/org/antlr/ /root/.m2/repository/org/antlr/
COPY --from=builder $SOURCE_ROOT/jdk-11.0.6+10 $SOURCE_ROOT/jdk-11.0.6+10
COPY --from=builder $SOURCE_ROOT/node-v12.14.1-linux-s390x $SOURCE_ROOT/node-v12.14.1-linux-s390x
COPY --from=builder $SOURCE_ROOT/apache-maven-3.3.9 $SOURCE_ROOT/apache-maven-3.3.9

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
