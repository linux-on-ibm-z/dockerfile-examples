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
# Start master of Hbase using below command :
# docker run -d --name <container_name> -p <host-port>:16010 <image-name> hbase master <command> 
# e.g. docker run -d --name hbase_test -p 16011:16010 hbase hbase master start 
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
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV PATH=$PATH:$JAVA_HOME/bin:$SOURCE_DIR/hbase/bin

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
  && cd $SOURCE_DIR \
  && git clone git://github.com/apache/hbase.git \
  && cd hbase/ \
  && git checkout rel/1.2.6 \
  && mvn install -DskipTests=true \
  && cd $SOURCE_DIR \
  && wget https://github.com/jnr/jffi/archive/1.0.0.tar.gz \
  && tar -xvf 1.0.0.tar.gz \
  && cd jffi-1.0.0/ \

# Edit the files
 && cp $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile.org \
 && sed -i '68d ' $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '68 i WFLAGS += -W -Wall -Wno-unused -Wno-parentheses -Wundef -Wno-unused-parameter' $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '159d ' $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && sed -i '159 i SOFLAGS = -shared -static-libgcc -Wl,-soname,$(@F) -Wl,-O1 ' $SOURCE_DIR/jffi-1.0.0/jni/GNUmakefile \
 && cp $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile.org \
 && sed -i '48d ' $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '48 i WFLAGS = -W -Werror -Wall -Wno-unused -Wno-parentheses -Wno-unused-parameter' $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '50d ' $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && sed -i '50 i SOFLAGS = -shared -Wl,-O1' $SOURCE_DIR/jffi-1.0.0/libtest/GNUmakefile \
 && ant | exit 0 \
 && mkdir -p $SOURCE_DIR/jar_tmp \
 && cp ~/.m2/repository/org/jruby/jruby-complete/1.6.8/jruby-complete-1.6.8.jar $SOURCE_DIR/jar_tmp \
 && cd $SOURCE_DIR/jar_tmp \
 && jar xf jruby-complete-1.6.8.jar \
 && mkdir -p jni/s390x-Linux \
 && cp $SOURCE_DIR/jffi-1.0.0/build/jni/libjffi-1.0.so jni/s390x-Linux/ \
 && jar uf jruby-complete-1.6.8.jar jni/s390x-Linux/libjffi-1.0.so \
 && mv $SOURCE_DIR/jar_tmp/jruby-complete-1.6.8.jar ~/.m2/repository/org/jruby/jruby-complete/1.6.8/jruby-complete-1.6.8.jar \

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
  && rm -rf $SOURCE_DIR/jar_tmp $SOURCE_DIR/1.0.0.tar.gz $SOURCE_DIR/jffi-1.0.0 /var/lib/apt/lists/*

# Define mount points for logs, conf files & data.
VOLUME ["$SOURCE_DIR/hbase/data", "$SOURCE_DIR/hbase/conf", "$SOURCE_DIR/hbase/logs"]

# Port for Apache Hbase
EXPOSE 2181 16010 60000 60010 60020 60030 8080 8085 9090 9095

# Set the Entrypoint
CMD ["hbase"]

# End of Dockerfile
