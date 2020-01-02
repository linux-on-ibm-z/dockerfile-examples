# © Copyright IBM Corporation 2019, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
##################### Dockerfile for Apache Spark version 2.4.4 ###################################################
#
# This Dockerfile builds a basic installation of Apache Spark.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Apache Spark server using this image, use following command:
# docker run --name <container name> -it -p <port>:4040 <image_name>
#
##################################################################################################################
# Base Image
FROM s390x/ubuntu:18.04 AS builder

ARG SPARK_VER=v2.4.4

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ARG PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ApacheSpark/2.4.4/Patch/"

ENV SOURCE_DIR=/root
WORKDIR $SOURCE_DIR

ENV JAVA_HOME /opt/adopt/jdk
ENV PATH $JAVA_HOME/bin:$PATH
ENV LEVELDB_HOME $SOURCE_DIR/leveldb
ENV LEVELDBJNI_HOME $SOURCE_DIR/leveldbjni
ENV LIBRARY_PATH ${SNAPPY_HOME}
ENV C_INCLUDE_PATH ${LIBRARY_PATH}
ENV CPLUS_INCLUDE_PATH ${LIBRARY_PATH}
ENV SNAPPY_HOME $SOURCE_DIR/snappy-1.1.3
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOURCE_DIR
ENV MAVEN_OPTS="-Xmx3g -XX:ReservedCodeCacheSize=1024m"

# Install the dependencies
RUN apt-get update -y  &&  apt-get install -y curl tar git libtool autoconf build-essential maven apt-transport-https\
# Download java
&& mkdir -p ${JAVA_HOME}      \
&& cd $SOURCE_DIR \
&& curl -SL -o java.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08_openj9-0.12.1/OpenJDK8U-jdk_s390x_linux_openj9_8u202b08_openj9-0.12.1.tar.gz \
&& tar -xvf java.tar.gz -C ${JAVA_HOME} --strip 1   \
# Build LevelDB JNI
&& cd $SOURCE_DIR \
&& curl -SLO  https://github.com/google/snappy/releases/download/1.1.3/snappy-1.1.3.tar.gz \
&& tar -zxvf snappy-1.1.3.tar.gz \
&& cd ${SNAPPY_HOME} \
&& ./configure --disable-shared --with-pic \
&& make \
&& make install \
&& cd $SOURCE_DIR \
&& git clone -b s390x https://github.com/linux-on-ibm-z/leveldb.git \
&& git clone -b leveldbjni-1.8-s390x https://github.com/linux-on-ibm-z/leveldbjni.git \
&& cd ${LEVELDB_HOME} \
&& git apply ${LEVELDBJNI_HOME}/leveldb.patch \
&& make libleveldb.a \
&& cd ${LEVELDBJNI_HOME} \
&& mvn clean install -P download -Plinux64-s390x -DskipTests \
&& jar -xvf ${LEVELDBJNI_HOME}/leveldbjni-linux64-s390x/target/leveldbjni-linux64-s390x-1.8.jar \
&& cp ${SOURCE_DIR}/leveldbjni/META-INF/native/linux64/s390x/libleveldbjni.so $SOURCE_DIR    \
# Build ZSTD JNI
&& cd $SOURCE_DIR \
&& echo "deb https://dl.bintray.com/sbt/debian /" |  tee -a /etc/apt/sources.list.d/sbt.list \
&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
&& apt-get update \
&& apt-get install sbt \
&& cd $SOURCE_DIR \
&& git clone https://github.com/luben/zstd-jni.git \
&& cd zstd-jni \
&& git checkout v1.3.8-2 \
&& sbt compile test package \
&& cp ${SOURCE_DIR}/zstd-jni/target/classes/linux/s390x/libzstd-jni.so $SOURCE_DIR \
&& ulimit -s unlimited \
&& ulimit -n 999999  \
# Build Apache Spark
&& cd $SOURCE_DIR \
&& git clone https://github.com/apache/spark.git \
&& cd spark \
&& git checkout $SPARK_VER  \
# Apply patches
&& curl -SL -o "Platform.diff"  $PATCH_URL/Platform.diff \
&& patch "${SOURCE_DIR}/spark/common/unsafe/src/main/java/org/apache/spark/unsafe/Platform.java" Platform.diff \
# Patch OffHeapColumnVector.diff
&& curl -SL -o "OffHeapColumnVector.diff"  $PATCH_URL/OffHeapColumnVector.diff \
&& patch "${SOURCE_DIR}/spark/sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OffHeapColumnVector.java" OffHeapColumnVector.diff \
# Patch OnHeapColumnVector.diff
&& curl -SL -o "OnHeapColumnVector.diff"  $PATCH_URL/OnHeapColumnVector.diff \
&& patch "${SOURCE_DIR}/spark/sql/core/src/main/java/org/apache/spark/sql/execution/vectorized/OnHeapColumnVector.java" OnHeapColumnVector.diff \
# Patch StatsdSinkSuite.diff file
&& curl -SL -o "StatsdSinkSuite.diff"  $PATCH_URL/StatsdSinkSuite.diff \
&& patch "${SOURCE_DIR}/spark/core/src/test/scala/org/apache/spark/metrics/sink/StatsdSinkSuite.scala" StatsdSinkSuite.diff \
# Patch Murmur3_x86_32Suite.diff
&& curl -SL -o "Murmur3_x86_32Suite.diff"  $PATCH_URL/Murmur3_x86_32Suite.diff \
&& patch "${SOURCE_DIR}/spark/common/unsafe/src/main/java/org/apache/spark/unsafe/hash/Murmur3_x86_32.java" Murmur3_x86_32Suite.diff \
# Patch UnsafeMapSuite.diff
&& curl -SL -o "UnsafeMapSuite.diff"  $PATCH_URL/UnsafeMapSuite.diff \
&& patch "${SOURCE_DIR}/spark/sql/catalyst/src/test/scala/org/apache/spark/sql/catalyst/util/UnsafeMapSuite.scala" UnsafeMapSuite.diff \
# Patch EventTimeWatermarkSuite.diff
&& curl -SL -o "EventTimeWatermarkSuite.diff"  $PATCH_URL/EventTimeWatermarkSuite.diff \
&& patch "${SOURCE_DIR}/spark/sql/core/src/test/scala/org/apache/spark/sql/streaming/EventTimeWatermarkSuite.scala" EventTimeWatermarkSuite.diff \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowConvertersSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowConvertersSuite.scala.orig \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ColumnarBatchSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ColumnarBatchSuite.scala.orig \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ArrowColumnVectorSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/vectorized/ArrowColumnVectorSuite.scala.orig \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowWriterSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowWriterSuite.scala.orig \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowUtilsSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/arrow/ArrowUtilsSuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcFilterSuite.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcFilterSuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcQuerySuite.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcQuerySuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/OrcHadoopFsRelationSuite.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/OrcHadoopFsRelationSuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcPartitionDiscoverySuite.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcPartitionDiscoverySuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcSourceSuite.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/HiveOrcSourceSuite.scala.orig \
&& mv sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/OrcReadBenchmark.scala sql/hive/src/test/scala/org/apache/spark/sql/hive/orc/OrcReadBenchmark.scala.orig \
&& mv sql/core/src/test/scala/org/apache/spark/sql/execution/python/ExtractPythonUDFsSuite.scala sql/core/src/test/scala/org/apache/spark/sql/execution/python/ExtractPythonUDFsSuite.scala.orig \
&& ./build/mvn -DskipTests clean package \
# Cleanup
&& rm -rf $SOURCE_DIR/zstd-jni \
&& rm -rf ${SNAPPY_HOME} \
&& rm -rf ${LEVELDBJNI_HOME} \
&& rm -rf ${SOURCE_DIR}/*.tar.gz

FROM s390x/ubuntu:18.04
RUN apt-get update -y

WORKDIR /root
COPY --from=builder /opt/adopt/jdk /opt/adopt/jdk
COPY --from=builder /root/spark/bin /opt/spark/bin
COPY --from=builder /root/spark/sbin /opt/spark/sbin
COPY --from=builder /root/spark/conf /opt/spark/conf
COPY --from=builder /root/spark/examples /opt/spark/examples
COPY --from=builder /root/spark/data /opt/spark/data
COPY --from=builder /root/spark/assembly /opt/spark/assembly

# Set Environment
ENV JAVA_HOME /opt/adopt/jdk
ENV PATH=$JAVA_HOME/bin:/opt/spark/bin:$PATH

# Run Spark
ENTRYPOINT spark-shell
