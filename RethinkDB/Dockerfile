# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for RethinkDB 2.4.1 ############################################
#
# This Dockerfile builds a basic installation of RethinkDB
#
# RethinkDB is an open-source, distributed database built to store JSON documents and effortlessly scale to 
# multiple machines. It's easy to set up and learn and features a simple but powerful query language that supports 
# table joins, groupings, aggregations, and functions.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Rethink use:
# docker run --name <container name> -p <port1>:8080 -p <port2>:28015 -p <port3>:29015 -d <image name>
#
################################################################################################################

# Base Image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV SOURCE_ROOT=/tmp/source
WORKDIR $SOURCE_ROOT
RUN apt-get update -y && apt-get install -y \ 
clang \
build-essential \
python \
libcurl4-openssl-dev \
libboost-all-dev \
libncurses5-dev \
wget \
m4 \
libssl-dev \
git \
curl \

#Install gcc-5.4.0
&& cd $SOURCE_ROOT \
&& mkdir gcc \
&& cd gcc \
&& wget https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz \
&& tar -xzf gcc-5.4.0.tar.gz \
&& cd gcc-5.4.0/ \
&& ./contrib/download_prerequisites \
&& mkdir objdir \
&& cd objdir \
&& ../configure --prefix=/opt/gcc --enable-languages=c,c++ --with-arch=zEC12 --with-long-double-128 \
  	   --build=s390x-linux-gnu --host=s390x-linux-gnu --target=s390x-linux-gnu                  \
  	   --enable-threads=posix --with-system-zlib --disable-multilib \
&& make -j 8 \
&& make install \
&& ln -sf /opt/gcc/bin/gcc /usr/bin/gcc \
&& ln -sf /opt/gcc/bin/g++ /usr/bin/g++ \
&& ln -sf /opt/gcc/bin/g++ /usr/bin/c++ \
&& export PATH=/opt/gcc/bin:"$PATH" \
&& export LD_LIBRARY_PATH=/opt/gcc/lib64:"$LD_LIBRARY_PATH" \
&& export C_INCLUDE_PATH=/opt/gcc/lib/gcc/s390x-linux-gnu/5.4.0/include \
&& export CPLUS_INCLUDE_PATH=/opt/gcc/lib/gcc/s390x-linux-gnu/5.4.0/include \

#Install Protobuf 2.6.0 
&& cd $SOURCE_ROOT \
&& wget https://github.com/google/protobuf/releases/download/v2.6.0/protobuf-2.6.0.tar.gz \
&& tar zxvf protobuf-2.6.0.tar.gz \
&& cd protobuf-2.6.0 \
&& sed -i '/elif defined(GOOGLE_PROTOBUF_ARCH_MIPS)/i #elif defined(GOOGLE_PROTOBUF_ARCH_S390)' src/google/protobuf/stubs/atomicops.h \
&& sed -i '/elif defined(GOOGLE_PROTOBUF_ARCH_MIPS)/i #include <google/protobuf/stubs/atomicops_internals_generic_gcc.h>' src/google/protobuf/stubs/atomicops.h \
&& sed -i '/#define GOOGLE_PROTOBUF_ARCH_64_BIT 1/a #elif defined(__s390x__)' src/google/protobuf/stubs/platform_macros.h \
&& sed -i '/#elif defined(__s390x__)/a #define GOOGLE_PROTOBUF_ARCH_S390 1' src/google/protobuf/stubs/platform_macros.h \
&& sed -i '/#define GOOGLE_PROTOBUF_ARCH_S390/a #define GOOGLE_PROTOBUF_ARCH_64_BIT 1' src/google/protobuf/stubs/platform_macros.h \
&& ./configure \
&& make \
&& make install \
&& export LD_LIBRARY_PATH=/usr/local/lib \
&& protoc --version \
#Clone and build RethinkDB
&& export VPYTHON_BYPASS="manually managed python not supported by chrome operations" \
&& cd $SOURCE_ROOT \
&& git clone https://github.com/rethinkdb/rethinkdb \
&& cd rethinkdb/ \
&& git checkout v2.4.1 \

#Changed for V8
 &&  cp mk/support/pkg/v8.sh mk/support/pkg/v8.sh.orig \
 && sed -i '67 i export CXXFLAGS="-fno-delete-null-pointer-checks"' mk/support/pkg/v8.sh \
 && sed -i '67 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '69d ' mk/support/pkg/v8.sh \
 && sed -i '69 i make dependencies || true'  mk/support/pkg/v8.sh \
 && sed -i '69 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '70d ' mk/support/pkg/v8.sh \
 && sed -i '70 i make s390x -j4 werror=no snapshot=off library=static'  mk/support/pkg/v8.sh \
 && sed -i '70 s/^/        /' mk/support/pkg/v8.sh \
 && sed -i '172d ' mk/support/pkg/v8.sh \
 && sed -i '172 i  for lib in libv8_{base,libbase,nosnapshot,libplatform}; do'  mk/support/pkg/v8.sh \
 && sed -i '172 s/^/        /' mk/support/pkg/v8.sh \
 

 && ./configure --allow-fetch \ 
 && make -j 4 \ 

#Install RethinkDB
 && make install \

# Clean up cache data and remove dependencies that are not required
 && apt-get remove -y \
    build-essential \
    git \
    make \
    m4 \
    protobuf-compiler \
    python \
    wget \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*  /$SOURCE_ROOT

VOLUME ["/data"]

WORKDIR /data

#   process cluster webui
EXPOSE 28015 29015 8080

#Start RethinkDB server
CMD rethinkdb --bind all
