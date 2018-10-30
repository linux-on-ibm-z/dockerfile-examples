# © Copyright IBM Corporation 2017, 2018
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################# Dockerfile for Marathon 1.7.50 #####################################
#
# This Dockerfile builds a basic installation of Marathon.
#
# Marathon is a production-grade container orchestration platform for Mesosphere’s Datacenter Operating System (DC/OS) and Apache Mesos.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Marathon run the below command:
# docker run --privileged --name <container_name> -p <portnumber>:8080 -d <image_name>
#
# Test in the browser by using the following url:
# http://<hostname>:<port_number>/
#
#####################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/tmp"

# Set the Environmental Variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x 
ENV JAVA_TOOL_OPTIONS='-Xmx2048M'
ENV PATH=$PATH:$JAVA_HOME/bin:/tmp/source_root/sbt/bin:/usr/share/zookeeper-3.4.8/bin:/usr/share/marathon/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

# Install dependencies
RUN apt-get update && apt-get install -y \
        git \
        openjdk-8-jdk \
        patch \
        tar \
        wget \
        build-essential \
        python-dev \
        libcurl4-nss-dev \
        libsasl2-dev \
        libsasl2-modules \
        maven \
        libapr1-dev \
        libsvn-dev \
        zlib1g-dev \
        libssl-dev \
        autoconf \
        automake \
        libtool \
        bzip2 \
        unzip \
        python-six \
        python-virtualenv \
# Install sbt
 && mkdir source_root && cd source_root \
 && wget https://github.com/sbt/sbt/releases/download/v1.1.1/sbt-1.1.1.tgz \
 && tar -zxf sbt-1.1.1.tgz \
# Clone Mesos
 && git clone https://github.com/apache/mesos \
 && cd mesos && git checkout 1.7.0 \
 && cd 3rdparty/ \
 && git clone -b v1.11.0 https://github.com/grpc/grpc.git grpc-1.11.0 \
 && cd grpc-1.11.0/ \
 && git submodule update --init third_party/cares \
 && cd ../ \
 && tar zcvf grpc-1.11.0.tar.gz --exclude .git grpc-1.11.0 \
 && rm -rf grpc-1.11.0 \
 && cd ../ \
# Add patch 
 && sed -i -e 's/1.10.0/1.11.0/g' 3rdparty/versions.am \
 && sed -i -e 's/1.10.0/1.11.0/g' src/python/native_common/ext_modules.py.in \
 && sed -i '87i \          \<maxmemory>512m</maxmemory>' src/java/mesos.pom.in \
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
# Build Mesos
 && ./bootstrap && mkdir build && cd build \
 && ../configure && make && make install \
# clone and install Marathon
 && cd /tmp/source_root && git clone https://github.com/mesosphere/marathon.git \
 && cd marathon && git checkout v1.7.50 \
 && sed -i -e 's/1.1.0/1.1.1/g' project/build.properties \
 && sed -i -e 's/2.12.4/2.12.6/g' build.sbt \
 && sbt stage \
 && cp -r /tmp/source_root/mesos/build/3rdparty/zookeeper-3.4.8 /usr/share/ \
 && cp -r /tmp/source_root/marathon /usr/share \
# Clean up source dir and unused packages/libraries
 && apt-get remove -y \
        patch \
        wget \
        maven \
        autoconf \
        automake \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /root/.m2 && rm -rf /tmp/source_root/m*

# Port for Marathon
EXPOSE 8080

# Start ZooKeeper service
RUN cd /usr/share/zookeeper-3.4.8 \
&& cp conf/zoo_sample.cfg conf/zoo.cfg

# Start Marathon master
CMD env PATH=$PATH zkServer.sh start \
&& env PATH=$PATH mesos-local \
&& cd /usr/share/marathon \
&& env PATH=$PATH sbt 'run --master 127.0.0.1:5050 --zk zk://127.0.0.1:2181/marathon'

# End of Dockerfile
