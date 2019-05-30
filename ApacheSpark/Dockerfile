# © Copyright IBM Corporation 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
##################### Dockerfile for Apache Spark version 2.3.2 ###################################################
#
# This Dockerfile builds a basic installation of Apache Spark.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Spark server using this image, use following command:
# docker run --name <container name> -d -p <port>:8080 <image name> 
#
##################################################################################################################
# Base Image
FROM s390x/ubuntu:16.04
ARG SPARK_VER=v2.3.2
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)" 
ENV SOURCE_DIR=/opt
WORKDIR $SOURCE_DIR
ENV JAVA_HOME /opt/jdk8u202-b08/
ENV PATH $JAVA_HOME/bin:$PATH
ENV LEVELDB_HOME $SOURCE_DIR/leveldb
ENV LEVELDBJNI_HOME $SOURCE_DIR/leveldbjni
ENV LIBRARY_PATH ${SNAPPY_HOME}
ENV C_INCLUDE_PATH ${LIBRARY_PATH}
ENV CPLUS_INCLUDE_PATH ${LIBRARY_PATH}
ENV SNAPPY_HOME $SOURCE_DIR/snappy-1.1.3
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOURCE_DIR
ENV MAVEN_OPTS="-Xmx2g -XX:ReservedCodeCacheSize=512m"
# Install the dependencies
RUN apt-get update -y  &&  apt-get install -y wget tar git libtool autoconf build-essential maven apt-transport-https\
# Download java
&& wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jdk_s390x_linux_openj9_8u202b08_openj9-0.12.0.tar.gz \
&& tar -xvf OpenJDK8U-jdk_s390x_linux_openj9_8u202b08_openj9-0.12.0.tar.gz \
# Build LevelDB JNI
&& cd $SOURCE_DIR \
&& wget https://github.com/google/snappy/releases/download/1.1.3/snappy-1.1.3.tar.gz \
&& tar -zxvf snappy-1.1.3.tar.gz \
&& cd ${SNAPPY_HOME} \
&& ./configure --disable-shared --with-pic \
&& make \
&& cd $SOURCE_DIR \
&& git clone -b s390x https://github.com/linux-on-ibm-z/leveldb.git \
&& git clone -b leveldbjni-1.8-s390x https://github.com/linux-on-ibm-z/leveldbjni.git \
&& cd ${LEVELDB_HOME} \
&& git apply ${LEVELDBJNI_HOME}/leveldb.patch \
&& make libleveldb.a \
&& cd ${LEVELDBJNI_HOME} \
&& mvn clean install -P download -Plinux64-s390x -DskipTests \
&& jar -xvf ${LEVELDBJNI_HOME}/leveldbjni-linux64-s390x/target/leveldbjni-linux64-s390x-1.8.jar \
&& cp /opt/leveldbjni/META-INF/native/linux64/s390x/libleveldbjni.so $SOURCE_DIR
# Build ZSTD JNI
RUN  cd $SOURCE_DIR \
&& echo "deb https://dl.bintray.com/sbt/debian /" |  tee -a /etc/apt/sources.list.d/sbt.list \
&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
&& apt-get update \
&& apt-get install sbt \
&& cd $SOURCE_DIR \
&& git clone https://github.com/luben/zstd-jni.git \
&& cd zstd-jni \
&& git checkout v1.3.8-2 \
&& sbt compile test package \
&& cp /opt/zstd-jni/target/classes/linux/s390x/libzstd-jni.so $SOURCE_DIR \
&& ulimit -s unlimited \
&& ulimit -n 999999 \
# Build Apache Spark
&& cd $SOURCE_DIR \
&& git clone https://github.com/apache/spark.git \
&& cd spark \
&& git checkout $SPARK_VER \
&& sed -i '46 i \String arch = System.getProperty("os.arch", "");\n' common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i '62d' common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i "62 i //Since java.nio.Bits.unaligned() doesn't return true on s390x" common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i '63 i  if(arch.matches("^(s390x|s390x)$")){' common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i "64 i  _unaligned=true;" common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i "65 i  }else{" common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i "66 i  _unaligned = Boolean.TRUE.equals(unalignedMethod.invoke(null)); \n }" common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java \
&& sed -i '399s/LITTLE/BIG/' sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OnHeapColumnVector.java \
&& sed -i '448s/LITTLE/BIG/' sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OnHeapColumnVector.java \
&& sed -i '420s/LITTLE/BIG/' sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OffHeapColumnVector.java \
&& sed -i '475s/LITTLE/BIG/' sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OffHeapColumnVector.java \
&& sed -i '449s/LITTLE/BIG/' sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ColumnarBatchSuite.scala \
&& sed -i '533s/LITTLE/BIG/' sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ColumnarBatchSuite.scala \
&& sed -i '39s/8192/10000/' core/src/test/scala/org/apache/spark/metrics/sink/StatsdSinkSuite.scala \
&& ./build/mvn -DskipTests clean package \
# Cleanup
&& rm -rf $SOURCE_DIR/zstd-jni \
&& rm -rf ${SNAPPY_HOME} \
&& rm -rf ${LEVELDBJNI_HOME}
ENV PATH=/opt/spark/bin:$PATH
# Run Spark
ENTRYPOINT spark-shell | tail -f /dev/null
