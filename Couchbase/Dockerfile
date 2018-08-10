# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

##################### Dockerfile for Couchbase version 5.1.0 ###################################################
#
# This Dockerfile builds a basic installation of Couchbase.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start Couchbase server using this image, use following command:
# docker run --name <container name> -p <port>:8091-8094 -p <port>:11210 -d <image name>
#
# Then you can access the Couchbase Web console using http://<host-ip>:<port_exported_8091>
#
##################################################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)


ENV SOURCE_DIR=/opt

WORKDIR $SOURCE_DIR

ENV JAVA_HOME /opt/ibm/java
ENV PATH $JAVA_HOME/bin:$PATH
ENV PATH $PATH:/usr/local/go/bin
ENV CB_MULTI_GO 0
ENV PATH $SOURCE_DIR/couchbase/install/bin:$PATH
ENV GOPATH=$HOME/go

# Install the Dependencies
RUN apt-get update -y && apt-get install -y\
    autoconf \
    automake \
    check \
    cmake \
    curl \
    flex \
    gcc-5 \
    git \
    g++-5 \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libncurses5-dev \
    libsnappy-dev \
    libssl-dev \
    libtool \
    libxml2-utils \
    make \
    openssl \
    pkg-config \
    python \
    python-dev \
    ruby \
    sqlite3 \
    subversion \
    tar \
    unixodbc \
    unixodbc-dev \
    vim \
    wget \
    xsltproc \
	golang-1.9 \
	xinetd \
 && export PATH=/usr/lib/go-1.9/bin:$PATH \
 && go version \ 
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 40 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 40 \
 && wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.17/linux/s390x/ibm-java-sdk-8.0-5.17-s390x-archive.bin \
 && wget https://raw.githubusercontent.com/zos-spark/scala-workbench/master/files/installer.properties.java \
 && tail -n +3 installer.properties.java | tee installer.properties \
 && chmod +x ibm-java-sdk-8.0-5.17-s390x-archive.bin \
 && ./ibm-java-sdk-8.0-5.17-s390x-archive.bin -r installer.properties \
 && java  -version \

# Install json
&& cd $SOURCE_DIR \
&& git clone https://github.com/nlohmann/json \
&& cd json \ 
&& export PATH=$PATH:`pwd` \

#install Boost 1.66.0
&& cd $SOURCE_DIR \
&& wget https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.gz \
&& tar -xvzf boost_1_66_0.tar.gz  \ 
&& ln -s $SOURCE_DIR/boost_1_66_0/boost /usr/include/boost \

# Install Erlang
 && cd $SOURCE_DIR \
 && git clone https://github.com/couchbasedeps/erlang.git \
 && cd erlang && git checkout couchbase-watson \
 && ./otp_build autoconf \
 && touch lib/debugger/SKIP lib/megaco/SKIP lib/observer/SKIP lib/wx/SKIP \
 && ./configure --prefix=/usr/local --enable-smp-support --disable-hipe --disable-fp-exceptions CFLAGS="-fno-strict-aliasing -O3 -ggdb3 -DOPENSSL_NO_EC=1" \
 && make -j$(cat /proc/cpuinfo | grep processor | wc -l) &&  make install \

# Install flatbuffers
 && cd $SOURCE_DIR && rm -rf flatbuffers \
 && git clone https://github.com/google/flatbuffers \
 && cd flatbuffers && git checkout v1.5.0 \
 && cp include/flatbuffers/flatbuffers.h include/flatbuffers/flatbuffers.h_org \
 && sed -i  '72 i  #define FLATBUFFERS_LITTLEENDIAN 0' include/flatbuffers/flatbuffers.h \
 && cmake -G "Unix Makefiles" && make && make install \
 && export PATH=$PATH:`pwd` \

# Install ICU 54.1
 && cd $SOURCE_DIR && git clone https://github.com/couchbasedeps/icu4c.git \
 && cd icu4c/source && git checkout r54.1 \
 && ./configure --prefix=/usr/local --disable-extras --disable-layout --disable-tests --disable-samples \
 && make &&  make install \


# Install Jemalloc 4.3.1
 && cd $SOURCE_DIR && git clone https://github.com/couchbasedeps/jemalloc.git \
 && cd jemalloc && git checkout 4.3.1 \
 && autoconf configure.ac > configure \
 && chmod u+x configure \
 && CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local --with-jemalloc-prefix=je_ --disable-cache-oblivious --disable-zone-allocator \
 && make build_lib_shared && make install_lib_shared install_include \

# Install v8 libraries
 && cd $SOURCE_DIR && git clone https://github.com/couchbasedeps/v8.git \
 && cd v8 && git checkout 5.2-couchbase \
 && sed -i '180d' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && sed -i '178d' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && sed -i '177d' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && sed -i '177 i \  dirent* entry = readdir(directory);' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && sed -i '179 i \  while (entry) {' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && sed -i '185 i \    entry = readdir(directory);' test/cctest/interpreter/generate-bytecode-expectations.cc \
 && make -j$(cat /proc/cpuinfo | grep processor | wc -l) s390x.release GYPFLAGS+="-Dcomponent=shared_library -Dv8_enable_backtrace=1 -Dv8_use_snapshot='true' -Dclang=0 -Dv8_use_external_startup_data=0 -Dv8_enable_i18n_support=0 -Dtest_isolation_mode=noop" PYTHONPATH=`pwd`/third_party/argparse-1.4.0 \
 && cp -vR include/* /usr/local/include/ \
 && cp -v out/s390x.release/lib.target/libv8.so /usr/local/lib/ \

# Install Repo tool
 && cd $SOURCE_DIR \
 && curl https://storage.googleapis.com/git-repo-downloads/repo > repo \
 && chmod a+x repo && mkdir -p $SOURCE_DIR/couchbase \
 && cd $SOURCE_DIR/couchbase \
 && git config --global user.email test@github.com \
 && git config --global user.name  test \
 && ../repo init -u git://github.com/couchbase/manifest -m released/5.1.0.xml \
 && ../repo sync \

# Edit tlm/CMakeLists.txt
 && cp tlm/CMakeLists.txt tlm/CMakeLists.txt.orig \
 && sed -i '68d ' tlm/CMakeLists.txt \
 && sed -i '68 i  SET(CB_DOWNLOAD_DEPS False' tlm/CMakeLists.txt \
 && sed -i '102d ' tlm/CMakeLists.txt \

# Edit forestdb/src/arch.h
 && cp forestdb/src/arch.h forestdb/src/arch.h.orig \
 && sed -i '317 i \        #if defined(__s390x__)\n\t\t#undef SPIN_INITIALIZER\n\t\t#define SPIN_INITIALIZER (spin_t)(0)\n\t#endif ' forestdb/src/arch.h \

# Edit couchstore/src/views/bin/couch_view_file_merger.cc
 && cp  couchstore/src/views/bin/couch_view_file_merger.cc  couchstore/src/views/bin/couch_view_file_merger.cc.orig \
 && sed -i '40s/.*/};typedef unsigned char merge_file_type_t;/' couchstore/src/views/bin/couch_view_file_merger.cc \

# Edit forestdb/utils/debug.cc
 && cp forestdb/utils/debug.cc forestdb/utils/debug.cc.orig \
 && sed -i '92 i #elif __s390x__ \n\t unsigned char *pc = (unsigned char *)u->uc_mcontext.psw.addr;' forestdb/utils/debug.cc \

# Edit CMakeLists.txt
 && cp platform/CMakeLists.txt platform/CMakeLists.txt.orig \
 && sed -i '168d ' platform/CMakeLists.txt \

# Edit platform/include/platform/crc32c.h
 && cp platform/include/platform/crc32c.h platform/include/platform/crc32c.h.orig \
 && sed -i '42d' platform/include/platform/crc32c.h \
 && sed -i '42 i #if !defined(__x86_64__) && !defined(_M_X64) && !defined(_M_IX86) && !defined(__s390x__)\n' platform/include/platform/crc32c.h \

# Edit platform/src/crc32c.cc
 && cd $SOURCE_DIR/couchbase && cp platform/src/crc32c.cc platform/src/crc32c.cc.orig \
 && sed -i ' 63d ' platform/src/crc32c.cc \
 && sed -i '63 i #elif defined(__clang__) || defined(__GNUC__) && !defined(__s390x__)' platform/src/crc32c.cc \
 && sed -i ' 371d ' platform/src/crc32c.cc \
 && sed -i '371 i \    //const uint32_t SSE42 = 0x00100000;' platform/src/crc32c.cc \
 && sed -i ' 374d ' platform/src/crc32c.cc \
 && sed -i '374 i /*' platform/src/crc32c.cc \
 && sed -i ' 386d ' platform/src/crc32c.cc \
 && sed -i '386 i */' platform/src/crc32c.cc \
 && sed -i '55 i #include <crc32-s390x.h>' platform/src/crc32c.cc \

# Edit platform/tests/CMakeLists.txt
 && cd $SOURCE_DIR/couchbase \
 && cp platform/tests/CMakeLists.txt platform/tests/CMakeLists.txt.orig \
 && sed -i '10d ' platform/tests/CMakeLists.txt \

# Edit goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go
 && cd $SOURCE_DIR/couchbase \
 && cp goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go.orig \
 && sed -i '77,82 d ' goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go \
 && sed -i '77 i \            s.freeNode = func(*Node) {} ' goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go \

# Edit kv_engine/daemon/subdocument_validators.cc
 && cp kv_engine/daemon/subdocument_validators.cc kv_engine/daemon/subdocument_validators.cc.orig \
 && sed -i ' 427d ' kv_engine/daemon/subdocument_validators.cc.orig \
 && sed -i '427 i \        (htonl(__bswap_32(req->request.bodylen)) < minimum_body_len) ||' kv_engine/daemon/subdocument_validators.cc \

# Edit benchmark/src/cycleclock.h
  && cp benchmark/src/cycleclock.h benchmark/src/cycleclock.h.orig \
  && sed -i '85 i #elif defined(__s390x__)\n\  uint64_t res;\n  __asm__ volatile("stck %0" : "=m"(res));\n  return res;' benchmark/src/cycleclock.h \

# Edit platform/include/platform/cacheline_padded.h
  && cp platform/include/platform/cacheline_padded.h platform/include/platform/cacheline_padded.h.orig \
  && sed -i '23d' platform/include/platform/cacheline_padded.h \
  && sed -i '23 i #define FALSE_SHARING_RANGE 64' platform/include/platform/cacheline_padded.h \
  
# Edit kv_engine/engines/ep/src/ep_engine.cc
  && cp kv_engine/engines/ep/src/ep_engine.cc kv_engine/engines/ep/src/ep_engine.cc.orig \
  && sed -i '3678d' kv_engine/engines/ep/src/ep_engine.cc \ 
  && sed -i '3678 i \        uint8_t keystatus = 0;'  kv_engine/engines/ep/src/ep_engine.cc \

# Edit kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc
 && cp kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc.orig \
 && sed -i '2362d' kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc \
 && sed -i '2362 i \    std::vector<char> junkMeta = {char(-2),char(-1),2,3};' kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc \
 
# Edit tlm/cmake/Modules/FindCouchbaseLibevent.cmake
 && cp tlm/cmake/Modules/FindCouchbaseLibevent.cmake tlm/cmake/Modules/FindCouchbaseLibevent.cmake.orig \
 && sed -i '47 i set(LIBEVENT_INCLUDE_DIR /usr/include)\nset(LIBEVENT_EXTRA_LIB /usr/lib/s390x-linux-gnu/libevent_extra.so)\nset(LIBEVENT_CORE_LIB /usr/lib/s390x-linux-gnu/libevent_core.so)\nset(LIBEVENT_THREAD_LIB /usr/lib/s390x-linux-gnu/libevent_pthreads.so)' tlm/cmake/Modules/FindCouchbaseLibevent.cmake \
 

# Replace BoltDB package
 && cd ./godeps/src/github.com/ && mv boltdb boltdb_ORIG \
 && mkdir boltdb && cd boltdb \
 && git clone https://github.com/boltdb/bolt.git \
 && cd bolt/ && git checkout v1.3.0 \


# Add the s390x crc32 support to the source code.
 && cd $SOURCE_DIR && git clone https://github.com/linux-on-ibm-z/crc32-s390x \
 && cd crc32-s390x && export CC=/usr/bin/gcc \
 && make && cp crc32-s390x.h /usr/local/include/ \
 && cp libcrc32_s390x.a /usr/local/lib/ \

# Install go tool yacc
 && cd $SOURCE_DIR && export GOPATH=$HOME/go \
 && go get -u golang.org/x/tools/cmd/goyacc \
 && cp $HOME/go/bin/goyacc /usr/lib/go-1.9/pkg/tool/linux_s390x/ \
 && chown root:root /usr/lib/go-1.9/pkg/tool/linux_s390x/goyacc \
 && chmod -f 755 /usr/lib/go-1.9/pkg/tool/linux_s390x/goyacc \
 && ln -sf /usr/lib/go-1.9/pkg/tool/linux_s390x/goyacc /usr/lib/go-1.9/pkg/tool/linux_s390x/yacc \

# Build the Couchbase
 && cd $SOURCE_DIR/couchbase/ && make \
 && mkdir -p /tmp/temp \
 && mv $SOURCE_DIR/couchbase/install/* /tmp/temp/ \
 && rm -rf $SOURCE_DIR/* && mkdir -p $SOURCE_DIR/couchbase/install/ \
 && mv /tmp/temp/* $SOURCE_DIR/couchbase/install/ \
 && apt-get remove -y \
    autoconf \
    automake \
    check \
    cmake \
    curl \
    flex \
    gcc-5 \
    git \
    g++-5 \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libmozjs-24-dev \
    libncurses5-dev \
    libtool \
    libxml2-utils \
    make \
    openssl \
    pkg-config \
    python \
    python-dev \
    ruby \
    sqlite3 \
    subversion \
    unixodbc \
    unixodbc-dev \
    vim \
    wget \
    xsltproc \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf $HOME/* 

# 8091: Couchbase Web console, REST/HTTP interface
# 8092: Views, queries, XDCR
# 8093: Query services (4.0+)
# 8094: Full-text Search (4.5+)
# 11207: Smart client library data node access (SSL)
# 11210: Smart client library/moxi data node access
# 11211: Legacy non-smart client library data node access
# 18091: Couchbase Web console, REST/HTTP interface (SSL)
# 18092: Views, query, XDCR (SSL)
# 18093: Query services (SSL) (4.0+)
EXPOSE 8091 8092 8093 8094 11207 11210 11211 18091 18092 18093

VOLUME $SOURCE_DIR/couchbase/install/var

CMD ["couchbase-server","-- -kernel","global_enable_tracing false -noinput"]
