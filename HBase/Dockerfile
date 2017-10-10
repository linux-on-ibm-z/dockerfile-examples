########## Dockerfile for Apache Hbase version 1.2.6 #########
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
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start master of Hbase using below command :
# docker run <container_name> -it -p <container-port> -v /<host>:/<container> <image-name> hbase master <command> 
# e.g. docker run --name hbase -it -p 8080 -v /root:/root/ hbase_img  hbase master start 
# 
# Official website: https://hbase.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV HADOOP_USER_NAME="hadoop"
ENV HIBERNATE_HOME=$SOURCE_DIR
ENV HBASE_DIR=$SOURCE_DIR
ENV PATH=$PATH:$JAVA_HOME/bin:$HBASE_DIR/hbase/bin

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \
  && apt-get install  -y \
			ant \
			gcc \
			git \
			make \
			maven \
			openjdk-8-jdk \
   			tar \
			wget \

# Download and build source code of Apache Hbase
  && cd $HIBERNATE_HOME \
  && git clone https://github.com/apache/hbase.git \
  && cd hbase/ \
  && git checkout rel/1.2.6 \
  && mvn install -DskipTests=true \
  && cd $HBASE_DIR \
  && wget https://github.com/jnr/jffi/archive/1.0.0.tar.gz \
  && tar -xvf 1.0.0.tar.gz \
  && cd jffi-1.0.0/ \

# Edit the files
 && cp $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile.org \
 && sed -i '68d ' $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '68 i WFLAGS += -W -Wall -Wno-unused -Wno-parentheses -Wundef -Wno-unused-parameter' $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '159d ' $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '159 i SOFLAGS = -shared -static-libgcc -Wl,-soname,$(@F) -Wl,-O1 ' $HBASE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && cp $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile.org \
 && sed -i '48d ' $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '48 i WFLAGS = -W -Werror -Wall -Wno-unused -Wno-parentheses -Wno-unused-parameter' $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '50d ' $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '50 i SOFLAGS = -shared -Wl,-O1' $HBASE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && ant | exit 0 \
 && mkdir -p $HBASE_DIR/jar_tmp \
 && cp ~/.m2/repository/org/jruby/jruby-complete/1.6.8/jruby-complete-1.6.8.jar $HBASE_DIR/jar_tmp \
 && cd $HBASE_DIR/jar_tmp \
 && jar xf jruby-complete-1.6.8.jar \
 && mkdir -p jni/s390x-Linux \
 && cp $HBASE_DIR/jffi-1.0.0/build/jni/libjffi-1.0.so jni/s390x-Linux/ \
 && jar uf jruby-complete-1.6.8.jar jni/s390x-Linux/libjffi-1.0.so \
 && mv $HBASE_DIR/jar_tmp/jruby-complete-1.6.8.jar ~/.m2/repository/org/jruby/jruby-complete/1.6.8/jruby-complete-1.6.8.jar \

# Clean up the unwanted packages and clear the source directory
 && apt-get remove -y \
			ant \
			gcc \
			git \
			make \
			maven \
			wget \

  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $HBASE_DIR/jar_tmp $SOURCE_DIR/1.0.0.tar.gz $SOURCE_DIR/jffi-1.0.0 /var/lib/apt/lists/*

VOLUME /data

# Port for Apache Hbase
EXPOSE 2181 60000 60010 60020 60030 8080 8085 9090 9095

# Set the Entrypoint
CMD ["hbase"]

# End of Dockerfile
