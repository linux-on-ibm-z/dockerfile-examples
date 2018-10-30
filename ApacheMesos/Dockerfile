########## Dockerfile for Apache Mesos version 1.7.0 #########
#
# This Dockerfile builds a basic installation of Apache Mesos.
#
# Apache Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks. 
# It can run Hadoop, Jenkins, Spark, Aurora, and other frameworks on a dynamically shared pool of nodes
# 
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container-name> -it <image_name> /bin/bash
#
# Start Master of Apache Mesos using below command :
# docker run --name <container_name> -d -p <host-port>:5050 <image-name> mesos-master.sh --ip=<ip-address> --work_dir=/var/lib/mesos --log_dir=/var/log/mesos
# e.g. docker run --name mesos -d -p 5055:5050 mesos:1.7.0 mesos-master.sh --ip=0.0.0.0 --work_dir=/var/lib/mesos --log_dir=/var/log/mesos
#
# Start Agent of Apache Mesos using below command :
# docker run --name <container_name> -d <image-name> mesos-agent.sh --master=<ip address of master>:<port of master> --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --launcher=posix
# 
# Official website: http://mesos.apache.org/
#
###################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR='/root'
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-s390x
ENV MESOS_HOME=/opt/mesos
ENV PATH=$PATH:$JAVA_HOME/bin:$MESOS_HOME/bin
ENV MESOS_work_dir=/var/lib/mesos
ENV MESOS_log_dir=/var/log/mesos
ENV MESOS_SYSTEMD_ENABLE_SUPPORT false
WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update  \
  && apt-get install  -y \
                        autoconf \
                        automake \
                        build-essential \
                        bzip2 \
                        git \
                        g++ \
                        libapr1-dev \
                        libcurl4-nss-dev \
                        libsasl2-dev \
                        libsasl2-modules \
                        libssl-dev \
                        libsvn-dev \
                        libtool \
                        maven \
                        openjdk-8-jdk \
                        python \
                        python-dev \
                        tar \
                        wget \
                        zlib1g-dev \

# Download and build source code of Apache Mesos
  && cd $SOURCE_DIR \
  && git clone https://github.com/apache/mesos \
  && cd $SOURCE_DIR/mesos/ \
  && git checkout 1.7.0 \
  
# Bundling gRPC-1.11.0  
  && cd 3rdparty/ \
  && git clone -b v1.11.0 https://github.com/grpc/grpc.git grpc-1.11.0 \
  && cd grpc-1.11.0/ \
  && git submodule update --init third_party/cares \
  && cd ../ \
  && tar zcvf grpc-1.11.0.tar.gz --exclude .git grpc-1.11.0 \
  && rm -rf grpc-1.11.0 \
  
  && cd $SOURCE_DIR/mesos/ \
  && sed -i '87i \          \<maxmemory>512m</maxmemory>' src/java/mesos.pom.in \

# Add patch for updated gRPC version
  && sed -i -e 's/1.10.0/1.11.0/g' 3rdparty/versions.am \
  && sed -i -e 's/1.10.0/1.11.0/g' src/python/native_common/ext_modules.py.in \
  
# Add patch for protobuf
  && echo "diff --git a/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h b/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "index 0b0b06c..075c406 100644" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "--- a/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+++ b/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "@@ -146,6 +146,14 @@ inline Atomic64 NoBarrier_Load(volatile const Atomic64* ptr) {" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "   return __atomic_load_n(ptr, __ATOMIC_RELAXED);" >> 3rdparty/protobuf-3.5.0.patch \
  && echo " }" >> 3rdparty/protobuf-3.5.0.patch \
  && echo >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+inline Atomic64 Release_CompareAndSwap(volatile Atomic64* ptr," >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+                                       Atomic64 old_value," >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+                                       Atomic64 new_value) {" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+  __atomic_compare_exchange_n(ptr, &old_value, new_value, false," >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+                              __ATOMIC_RELEASE, __ATOMIC_ACQUIRE);" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+  return old_value;" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+}" >> 3rdparty/protobuf-3.5.0.patch \
  && echo "+" >> 3rdparty/protobuf-3.5.0.patch \
  && echo " #endif // defined(__LP64__)" >> 3rdparty/protobuf-3.5.0.patch \
  && echo >> 3rdparty/protobuf-3.5.0.patch \
  && echo " }  // namespace internal" >> 3rdparty/protobuf-3.5.0.patch \
 
  && ./bootstrap \
  && mkdir build && cd build \
  && ../configure && make && make install \

# Edit the Files
  && mkdir -p /opt/mesos/src \
  && mkdir -p /opt/mesos/src/.libs \
  && mkdir -p /opt/mesos/3rdparty \

  && cp -a $SOURCE_DIR/mesos/build/bin /opt/mesos \
  && cp -a $SOURCE_DIR/mesos/build/src/master /opt/mesos/src \
  && cp -a $SOURCE_DIR/mesos/build/src/slave /opt/mesos/src \
  && cp $SOURCE_DIR/mesos/build/src/.libs/* /opt/mesos/src/.libs/ \
  && cp -r $SOURCE_DIR/mesos/build/3rdparty/* /opt/mesos/3rdparty/ \
  && cp -a $SOURCE_DIR/mesos/src/webui /opt/mesos/src \
  && find $SOURCE_DIR/mesos/build/src/ -maxdepth 1 -type f -exec cp {} /opt/mesos/src \; \

  && sed -i "22s/.*/. \/opt\/mesos\/bin\/mesos-master-flags.sh/" /opt/mesos/bin/mesos-master.sh \
  && sed -i "24s/.*/exec \/opt\/mesos\/src\/mesos-master \"\$\{\@\}\"/" /opt/mesos/bin/mesos-master.sh \
  && sed -i "s/\/root\/mesos\/build\/src/\/opt\/mesos\/src/g" /opt/mesos/src/mesos-master \

  && sed -i "22s/.*/. \/opt\/mesos\/bin\/mesos-agent-flags.sh/" /opt/mesos/bin/mesos-agent.sh \
  && sed -i "24s/.*/exec \/opt\/mesos\/src\/mesos-agent \"\$\{\@\}\"/" /opt/mesos/bin/mesos-agent.sh \
  && sed -i "s/\/root\/mesos\/build\/src/\/opt\/mesos\/src/g" /opt/mesos/src/mesos-agent \

  && sed -i "s|/root/mesos/build/../src/webui|/opt/mesos/src/webui|" /opt/mesos/bin/mesos-master-flags.sh \
  && sed -i "s|/root/mesos/build/src|/opt/mesos/src|" /opt/mesos/bin/mesos-agent-flags.sh \

  && sed -i "23s|/root/mesos/build/../src/cli|/opt/mesos/src/cli|" /opt/mesos/bin/mesos.sh \
  && sed -i "26s|/root/mesos/build/src|/opt/mesos/src|" /opt/mesos/bin/mesos.sh \
  && sed -i "30s|/root/mesos/build/src/mesos|/opt/mesos/src/mesos|" /opt/mesos/bin/mesos.sh \

# Clean up the unwanted packages and clear the source directory
  && apt-get remove -y \
                        autoconf \
                        automake \
                        build-essential \
                        bzip2 \
                        git \
                        libtool \
                        maven \
                        python \
                        python-dev \
                        wget \

  && apt-get autoremove -y \
  && apt autoremove -y \
  && apt-get clean \
  && rm -rf $SOURCE_DIR/mesos /var/lib/apt/lists/* /root/.m2

# Define mount point for important info like replicated logs of mesos
VOLUME ["/var/lib/mesos", "/var/log/mesos"]

# Port for Apache Mesos
EXPOSE 5050

# Set Entrypoint 
CMD mesos

# End of Dockerfile
