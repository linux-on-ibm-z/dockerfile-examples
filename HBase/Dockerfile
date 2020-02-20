# © Copyright IBM Corporation 2019, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Apache Hbase version 2.2.0 #########
#
# This Dockerfile builds a basic installation of Apache Hbase.
#
# Apache HBase is an open-source, distributed, versioned, non-relational database modeled after Google's Bigtable: A Distributed Storage System for Structured Data by Chang et al
# Apache HBase provides Bigtable-like capabilities on top of Hadoop and HDFS.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start master of Hbase using below command :
# docker run -d --name <container_name> -p <host-port>:16010 <image-name> master <command> 
# e.g. docker run -d --name hbase_test -p 16011:16010 hbase master start 
# 
# Start Hbase shell( which connect to running instance of HBase) using below command :
# docker exec -it <container id/name> hbase shell
# e.g. docker exec -it hbase_test hbase shell
# 
# To provide custom configuration for Hbase use below command:
#  docker run --name <container_name> -d -p <host-port>:16010 -v /<host_path>/hbase-env.sh:/root/hbase/conf/hbase-env.sh -v /<host_path>/hbase-site.xml:/root/hbase/conf/hbase-site.xml <image-name>
#
# Official website: https://hbase.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR='/root'
ENV JAVA_HOME='/usr/lib/jvm/java-8-openjdk-s390x'
ENV MAVEN_OPTS='-Xms1024m -Xmx4000m -XX:MaxPermSize=1024m'
ENV PATH=$PATH:$JAVA_HOME/bin:$SOURCE_DIR/hbase/bin

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \
  && apt-get install  -y \
      ant \
      gcc \
      g++ \
      git \
      make \
      maven \
      openjdk-8-jdk \
      tar \
      wget \
      autoconf curl unzip automake gzip libtool
# Download and build source code of Apache Hbase
RUN cd $SOURCE_DIR \
  && git clone git://github.com/apache/hbase.git \
  && cd hbase/ \
  && git checkout rel/2.2.0 \
# Build Protobuf 2.5.0 and 3.5.1
  && wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz\
  && tar zxvf protobuf-2.5.0.tar.gz && cd protobuf-2.5.0 \
  && wget https://raw.githubusercontent.com/google/protobuf/v2.6.0/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h -P src/google/protobuf/stubs/ \
  && sed -i '185i #elif defined\(GOOGLE_PROTOBUF_ARCH_S390\) \n#include \<google\/protobuf\/stubs\/atomicops_internals_generic_gcc.h\>' src/google/protobuf/stubs/atomicops.h \
  && sed -i '60i #elif defined\(__s390x__\)\n#define GOOGLE_PROTOBUF_ARCH_S390 1\n#define GOOGLE_PROTOBUF_ARCH_64_BIT 1' src/google/protobuf/stubs/platform_macros.h \
  && ./configure && make \
  && cd ../ && git clone https://github.com/protocolbuffers/protobuf.git \
  && cd protobuf && git checkout v3.5.1 && git submodule update --init --recursive \
  && sed -i '148i inline Atomic64 Release_CompareAndSwap\(volatile Atomic64* ptr, Atomic64 old_value, Atomic64 new_value\) {\n __atomic_compare_exchange_n\(ptr, \&old_value, new_value, false, __ATOMIC_RELEASE, __ATOMIC_ACQUIRE\)\;\n return old_value\;\n\}' src/google/protobuf/stubs/atomicops_internals_generic_gcc.h \
  && ./autogen.sh && ./configure && make \
  && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOURCE_DIR/hbase/protobuf/src/.libs:$SOURCE_DIR/hbase/protobuf-2.5.0/src/.libs && cd ../ \ 
  && mvn install:install-file -DgroupId=com.google.protobuf -DartifactId=protoc -Dversion=2.5.0 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/hbase/protobuf-2.5.0/src/.libs/protoc \
  && mvn install:install-file -DgroupId=com.google.protobuf -DartifactId=protoc -Dversion=3.5.1-1 -Dclassifier=linux-s390_64 -Dpackaging=exe -Dfile=$SOURCE_DIR/hbase/protobuf/src/.libs/protoc \
# Continue with build and install
  && mvn install -DskipTests=true \
  && cd $SOURCE_DIR \
  && wget https://github.com/jnr/jffi/archive/1.2.0.tar.gz \
  && tar -xvf 1.2.0.tar.gz \
  && cd jffi-1.2.0/ \
# Edit the files
 && cp $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile.org \
 && sed -i '71d ' $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile \
 && sed -i '71i WFLAGS += -W -Wall -Wno-unused -Wno-parentheses -Wundef -Wno-unused-parameter' $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile \
 && sed -i '186d ' $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile \
 && sed -i '186i SOFLAGS = -shared -static-libgcc -Wl,-soname,$(@F) -Wl,-O1 ' $SOURCE_DIR/jffi-1.2.0/jni/GNUmakefile \
 && cp $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile.org \
 && sed -i '48d ' $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile \
 && sed -i '48 i WFLAGS = -W -Werror -Wall -Wno-unused -Wno-parentheses -Wno-unused-parameter' $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile \
 && sed -i '50d ' $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile \
 && sed -i '50 i SOFLAGS = -shared -Wl,-O1' $SOURCE_DIR/jffi-1.2.0/libtest/GNUmakefile \
 && ant jar | exit 0 \
 && mkdir -p $SOURCE_DIR/jar_tmp \
 && cp ~/.m2/repository/org/jruby/jruby-complete/9.1.13.0/jruby-complete-9.1.13.0.jar $SOURCE_DIR/jar_tmp \
 && cd $SOURCE_DIR/jar_tmp \
 && jar xf jruby-complete-9.1.13.0.jar \
 && mkdir -p jni/s390x-Linux \
 && cp $SOURCE_DIR/jffi-1.2.0/build/jni/libjffi-1.2.so jni/s390x-Linux/ \
 && jar uf jruby-complete-9.1.13.0.jar jni/s390x-Linux/libjffi-1.2.so \
 && mv $SOURCE_DIR/jar_tmp/jruby-complete-9.1.13.0.jar ~/.m2/repository/org/jruby/jruby-complete/9.1.13.0/jruby-complete-9.1.13.0.jar \
# Clean up the unwanted packages and clear the source directory
 && apt-get remove -y \
      ant \
      gcc \
      git \
      make \
      maven \
      wget \
      autoconf automake libtool \
  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/jar_tmp $SOURCE_DIR/1.2.0.tar.gz $SOURCE_DIR/jffi-1.2.0 /var/lib/apt/lists/* \
      $SOURCE_DIR/hbase/.git $SOURCE_DIR/hbase/protobuf-2.5.0.tar.gz 

# Define mount points for logs, conf files & data.
VOLUME ["$SOURCE_DIR/hbase/data", "$SOURCE_DIR/hbase/conf", "$SOURCE_DIR/hbase/logs"]

# Port for Apache Hbase
EXPOSE 2181 16010 60000 60010 60020 60030 8080 8085 9090 9095

# Set the Entrypoint
ENTRYPOINT ["hbase"]

# End of Dockerfile
