# © Copyright IBM Corporation  2017, 2022
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Couchbase version 6.0.4 ############
#
# Couchbase is open source database software.
#
# To build Couchbase image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start Couchbase server run the below command
# docker run --name <container_name> -p <port_numbers>:8091-8094 -p <port_number>:11210 -d <image_name>
#
# To test Couchbase service, use following command:
# curl http://127.0.0.1:8091/ui/index.html
#
##################################################################################

# Base image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV SOURCE_ROOT=/tmp/source
ENV JAVA_HOME=/opt/ibm/java
ENV PATH=$JAVA_HOME/bin:/usr/lib/go-1.10/bin:$PATH:$SOURCE_ROOT/json:$SOURCE_ROOT/flatbuffers
ENV CC=/usr/bin/gcc
ENV CB_MULTI_GO=0
ENV GOPATH=/root/go
WORKDIR $SOURCE_ROOT

# Install base dependencies
RUN apt-get update  && apt-get install -y \
 autoconf automake check cmake curl flex gcc-5 git g++-5 libcurl4-gnutls-dev \
 libevent-dev libglib2.0-dev libncurses5-dev libsnappy-dev libssl1.0-dev \
 libtool libxml2-utils make openssl pkg-config python python-dev ruby sqlite3 \
 tar unixodbc unixodbc-dev wget xsltproc golang-1.10 patch xinetd \
 xutils-dev \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 40 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 40 \
# Install openssl
 && wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2h.tar.gz  \
 && tar zxf openssl-1.0.2h.tar.gz \
 && cd $SOURCE_ROOT/openssl-1.0.2h \
 && ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic \
 && make depend \
 && make && make install \
# Install Java
 && cd $SOURCE_ROOT \
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.7.5/linux/s390x/ibm-java-s390x-sdk-8.0-7.5.bin \
 && wget https://raw.githubusercontent.com/zos-spark/scala-workbench/master/files/installer.properties.java \
 && tail -n +3 installer.properties.java | tee installer.properties \
 && chmod +x ibm-java-s390x-sdk-8.0-7.5.bin \
 && ./ibm-java-s390x-sdk-8.0-7.5.bin -r installer.properties \
 && java -version \
# Install additional dependencies
 && cd $SOURCE_ROOT \
 && curl -SLO https://raw.githubusercontent.com/linux-on-ibm-z/dockerfile-examples/master/Couchbase/couchbase-6.0.4.patch \
 && curl -SLO https://raw.githubusercontent.com/linux-on-ibm-z/dockerfile-examples/master/Couchbase/flatbuffers.patch \
 && git clone https://github.com/nlohmann/json \
 && wget https://boostorg.jfrog.io/artifactory/main/release/1.69.0/source/boost_1_69_0.tar.gz \
 && tar -xzf boost_1_69_0.tar.gz \
 && ln -s $SOURCE_ROOT/boost_1_69_0/boost /usr/include/boost \
 && cd $SOURCE_ROOT && git clone https://github.com/couchbasedeps/erlang.git \
 && cd $SOURCE_ROOT/erlang \
 && git checkout couchbase-watson  \
 && ./otp_build autoconf  \
 && touch lib/debugger/SKIP lib/megaco/SKIP lib/observer/SKIP lib/wx/SKIP  \
 &&  ./configure --prefix=/usr/local --enable-smp-support --disable-hipe --disable-fp-exceptions CFLAGS="-fno-strict-aliasing -O3 -ggdb3" \
 && make -j$(cat /proc/cpuinfo | grep processor | wc -l) && make install  \
 && hash -r \
 && cd $SOURCE_ROOT && git clone https://github.com/google/flatbuffers \
 && cd $SOURCE_ROOT/flatbuffers \
 && git checkout v1.5.0 \
 && patch -p1 < $SOURCE_ROOT/flatbuffers.patch \
 && cmake -G "Unix Makefiles" \
 && make && make install \
 && hash -r \
 && cd $SOURCE_ROOT && git clone https://github.com/couchbasedeps/icu4c.git \
 && cd $SOURCE_ROOT/icu4c/source \
 && git checkout r54.1 \
 && ./configure --prefix=/usr/local --disable-extras --disable-layout --disable-tests --disable-samples \
 && make && make install \
 && hash -r \
 && cd $SOURCE_ROOT && git clone https://github.com/couchbasedeps/jemalloc.git \
 && cd $SOURCE_ROOT/jemalloc \
 && git checkout 4.3.1 \
 && autoconf configure.ac > configure \
 && chmod u+x configure \
 && CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local --with-jemalloc-prefix=je_ --disable-cache-oblivious --disable-zone-allocator --enable-prof \
 && make build_lib_shared \
 && make install_lib_shared install_include \
 && cd $SOURCE_ROOT && git clone https://github.com/couchbasedeps/v8.git \
 && cd $SOURCE_ROOT/v8 \
 && git checkout 5.9-couchbase \
 && make -j$(cat /proc/cpuinfo | grep processor | wc -l) s390x.release GYPFLAGS+="-Dcomponent=shared_library -Dv8_enable_backtrace=1 -Dv8_use_snapshot='true' -Dclang=0 -Dv8_use_external_startup_data=0 -Dv8_enable_i18n_support=0 -Dtest_isolation_mode=noop" PYTHONPATH=`pwd`/third_party/argparse-1.4.0 \
 && cp -vR include/* /usr/local/include/ \
 && chmod 644 /usr/local/include/libplatform/libplatform.h \
 && chmod 644 /usr/local/include/v8*h \
 && cp -v out/s390x.release/lib.target/libv8*.so /usr/local/lib/ \
 && chmod -f 755 /usr/local/lib/libv8*.so \
# Download the repo tool
 && cd $SOURCE_ROOT && curl https://storage.googleapis.com/git-repo-downloads/repo > repo \
 && chmod a+x repo \
 && mkdir couchbase && cd couchbase \
# Clone Couchbase
 && git config --global user.email your@email.addr  \
 && git config --global user.name  your_docker_name \
 && ../repo init -u https://github.com/couchbase/manifest -m released/couchbase-server/6.0.4.xml \
 && ../repo sync \
 && cd $SOURCE_ROOT \
# Patch files
 && patch -p0 < $SOURCE_ROOT/couchbase-6.0.4.patch \
# Replace Boltdb
 && cd $SOURCE_ROOT/couchbase/godeps/src/github.com/ \
 && mv boltdb boltdb_ORIG \
 && mkdir boltdb && cd boltdb \
 && git clone https://github.com/boltdb/bolt.git \
 && cd $SOURCE_ROOT/couchbase/godeps/src/github.com/boltdb/bolt \
 && git checkout v1.3.0 \
# Install s390x crc32 support
 && cd $SOURCE_ROOT && git clone https://github.com/linux-on-ibm-z/crc32-s390x.git \
 && cd $SOURCE_ROOT/crc32-s390x \
 && make \
 && cp crc32-s390x.h /usr/local/include/ \
 && cp libcrc32_s390x.a /usr/local/lib/ \
# Update the sys package
 && cd $SOURCE_ROOT/couchbase/godeps/src/golang.org/x/ \
 && mv sys sys_ORIG \
 && git clone https://github.com/golang/sys.git \
# Install go tool yacc
 && go get -u golang.org/x/tools/cmd/goyacc \
 && cp $HOME/go/bin/goyacc /usr/lib/go-1.10/pkg/tool/linux_s390x/ \
 && chown root:root /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc \
 && chmod -f 755 /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc \
 && ln -sf /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc /usr/lib/go-1.10/pkg/tool/linux_s390x/yacc \
# Build Couchbase
 && cd $SOURCE_ROOT/couchbase \
 && make \
# Clean up cache data and remove dependencies which are not required
 && apt-get -y remove autoconf automake check cmake curl flex gcc-5 git g++-5 libcurl4-openssl-dev libglib2.0-dev libncurses5-dev libssl-dev libtool libxml2-utils make openssl pkg-config python python-dev ruby sqlite3 subversion unixodbc unixodbc-dev wget xsltproc golang-1.10 patch xinetd xutils-dev \
 && apt autoremove -y \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm $SOURCE_ROOT/*.tar.gz && rm $SOURCE_ROOT/*.bin \
 && rm -rf $SOURCE_ROOT/openssl-1.0.2h \
 && rm -rf $SOURCE_ROOT/boost_1_69_0 \
 && rm -rf $SOURCE_ROOT/erlang \
 && rm -rf $SOURCE_ROOT/icu4c \
 && rm -rf $SOURCE_ROOT/v8 \
 && rm -rf $SOURCE_ROOT/crc32-s390x \
 && rm -rf $SOURCE_ROOT/flatbuffers \
 && rm -rf $SOURCE_ROOT/json \
 && rm -rf $SOURCE_ROOT/jemalloc \
 && rm -rf $SOURCE_ROOT/couchbase/build \
 && rm -rf $SOURCE_ROOT/*.patch

# 8091: Couchbase Web console, REST/HTTP interface
# 8092: Views, queries, XDCR
# 8093: Query services (4.0+)
# 8094: Full-text Search (4.5+)
# 8095: Analytics (5.5+)
# 8096: Eventing (5.5+)
# 11207: Smart client library data node access (SSL)
# 11210: Smart client library/moxi data node access
# 11211: Legacy non-smart client library data node access
# 18091: Couchbase Web console, REST/HTTP interface (SSL)
# 18092: Views, query, XDCR (SSL)
# 18093: Query services (SSL) (4.0+)
# 18094: Full-text Search (SSL) (4.5+)
# 18095: Analytics (SSL) (5.5+)
# 18096: Eventing (SSL) (5.5+)
EXPOSE 8091 8092 8093 8094 8095 8096 11207 11210 11211 18091 18092 18093 18094 18095 18096

# Start the server
CMD $SOURCE_ROOT/couchbase/install/bin/couchbase-server -- -noinput
