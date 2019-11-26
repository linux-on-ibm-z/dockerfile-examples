# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############### Dockerfile for Couchbase version 6.0.2 ############
#
# Couchbase is open source database software.
#
# To build Couchbase image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t couchbase .
#
# To start Couchbase server run the below command
# run -d --name db -p 8091-8094:8091-8094 -p 11210:11210 couchbase
#
# To test Couchbase service, use following command:
# curl http://127.0.0.1:8091/ui/index.html
#
##################################################################################

# Base image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV SOURCE_ROOT=/tmp/source
WORKDIR $SOURCE_ROOT

# Install base dependencies
RUN apt-get update  &&\
 apt-get install -y autoconf automake check cmake curl flex gcc-5 git g++-5 libcurl4-gnutls-dev libevent-dev libglib2.0-dev libncurses5-dev libsnappy-dev libssl1.0-dev libtool libxml2-utils make openssl pkg-config python python-dev ruby sqlite3 subversion tar unixodbc unixodbc-dev vim wget xsltproc golang-1.10 patch xinetd  &&\
 update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 40  &&\
 update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 40
ENV PATH=/usr/lib/go-1.10/bin:$PATH

# Install openssl
RUN wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2h.tar.gz  &&\
 tar zxf openssl-1.0.2h.tar.gz
WORKDIR $SOURCE_ROOT/openssl-1.0.2h
RUN ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic  &&\
 make depend  &&\
 make && make install

# Install Java
WORKDIR $SOURCE_ROOT
RUN echo 'LICENSE_ACCEPTED=TRUE\n\
USER_INSTALL_DIR=/opt/ibm/java-s390x-80\n\
-fileOverwrite_/opt/ibm/java-s390x-80/_uninstall/uninstall.lax=Yes\n'\
> installer.properties  &&\
 wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.5.41/linux/s390x/ibm-java-s390x-sdk-8.0-5.41.bin  &&\
 chmod a+x ibm-java-s390x-sdk-8.0-5.41.bin  &&\
 ./ibm-java-s390x-sdk-8.0-5.41.bin -i silent
ENV JAVA_HOME /opt/ibm/java-s390x-80
ENV PATH $JAVA_HOME/bin:$PATH
RUN java -version

# Install additional dependencies
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/nlohmann/json
ENV PATH $PATH:$SOURCE_ROOT/json
RUN echo $PATH  &&\
 wget https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz  &&\
 tar -xvzf boost_1_69_0.tar.gz  &&\
 ln -s $SOURCE_ROOT/boost_1_69_0/boost /usr/include/boost  &&\
 git clone https://github.com/couchbasedeps/erlang.git
WORKDIR $SOURCE_ROOT/erlang
RUN git checkout couchbase-watson  &&\
 ./otp_build autoconf  &&\
 touch lib/debugger/SKIP lib/megaco/SKIP lib/observer/SKIP lib/wx/SKIP  &&\
 ./configure --prefix=/usr/local --enable-smp-support --disable-hipe --disable-fp-exceptions CFLAGS="-fno-strict-aliasing -O3 -ggdb3"  &&\
 make -j$(cat /proc/cpuinfo | grep processor | wc -l) && make install  &&\
 hash -r
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/google/flatbuffers
WORKDIR $SOURCE_ROOT/flatbuffers
RUN git checkout v1.5.0
WORKDIR $SOURCE_ROOT
RUN echo '+++ flatbuffers/include/flatbuffers/flatbuffers.h' > flatbuffers.h.patch &&\
 echo '@@ -69,6 +69,7 @@' >> flatbuffers.h.patch &&\
 echo '' >> flatbuffers.h.patch &&\
 echo " // The wire format uses a little endian encoding (since that's efficient for" >> flatbuffers.h.patch &&\
 echo " // the common platforms)." >> flatbuffers.h.patch &&\
 echo '+#define FLATBUFFERS_LITTLEENDIAN 0' >> flatbuffers.h.patch &&\
 echo ' #if !defined(FLATBUFFERS_LITTLEENDIAN)' >> flatbuffers.h.patch &&\
 echo ' 	#if defined(__GNUC__) || defined(__clang__)' >> flatbuffers.h.patch &&\
 echo ' #ifdef __BIG_ENDIAN__' >> flatbuffers.h.patch &&\
 patch -p0 < flatbuffers.h.patch
WORKDIR $SOURCE_ROOT/flatbuffers
RUN cmake -G "Unix Makefiles" &&\
 make
ENV PATH $PATH:$SOURCE_ROOT/flatbuffers
RUN make install &&\
 hash -r
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/couchbasedeps/icu4c.git
WORKDIR $SOURCE_ROOT/icu4c/source
RUN git checkout r54.1 &&\
 ./configure --prefix=/usr/local --disable-extras --disable-layout --disable-tests --disable-samples &&\
 make &&\
 make install &&\
 hash -r
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/couchbasedeps/jemalloc.git
WORKDIR $SOURCE_ROOT/jemalloc
RUN git checkout 4.3.1 &&\
 autoconf configure.ac > configure &&\
 chmod u+x configure &&\
 CPPFLAGS=-I/usr/local/include ./configure --prefix=/usr/local --with-jemalloc-prefix=je_ --disable-cache-oblivious --disable-zone-allocator --enable-prof &&\
 make build_lib_shared &&\
 make install_lib_shared install_include
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/couchbasedeps/v8.git
WORKDIR $SOURCE_ROOT/v8
RUN git checkout 5.9-couchbase &&\
 make -j$(cat /proc/cpuinfo | grep processor | wc -l) s390x.release GYPFLAGS+="-Dcomponent=shared_library -Dv8_enable_backtrace=1 -Dv8_use_snapshot='true' -Dclang=0 -Dv8_use_external_startup_data=0 -Dv8_enable_i18n_support=0 -Dtest_isolation_mode=noop" PYTHONPATH=`pwd`/third_party/argparse-1.4.0 &&\
 cp -vR include/* /usr/local/include/ &&\
 chmod 644 /usr/local/include/libplatform/libplatform.h &&\
 chmod 644 /usr/local/include/v8*h &&\
 cp -v out/s390x.release/lib.target/libv8*.so /usr/local/lib/ &&\
 chmod -f 755 /usr/local/lib/libv8*.so

# Download the repo tool
WORKDIR $SOURCE_ROOT
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo &&\
 chmod a+x repo &&\
 mkdir couchbase

# Clone Couchbase
WORKDIR $SOURCE_ROOT/couchbase
RUN git config --global user.email your@email.addr &&\
 git config --global user.name  your_docker_name &&\
 ../repo init -u git://github.com/couchbase/manifest -m released/couchbase-server/6.0.2.xml &&\
 ../repo sync
WORKDIR $SOURCE_ROOT

# Patch files
RUN echo '+++ couchbase/tlm/CMakeLists.txt' >> CMakeLists.txt.patch &&\
 echo '@@ -73,7 +73,7 @@' >> CMakeLists.txt.patch &&\
 echo '' >> CMakeLists.txt.patch &&\
 echo ' # Try to download the prebuilt 3rd-party dependencies by default' >> CMakeLists.txt.patch &&\
 echo ' IF (NOT DEFINED CB_DOWNLOAD_DEPS)' >> CMakeLists.txt.patch &&\
 echo '-   SET(CB_DOWNLOAD_DEPS True' >> CMakeLists.txt.patch &&\
 echo '+   SET(CB_DOWNLOAD_DEPS False' >> CMakeLists.txt.patch &&\
 echo '        CACHE BOOL "Download prebuilt dependencies by default")' >> CMakeLists.txt.patch &&\
 echo ' ENDIF (NOT DEFINED CB_DOWNLOAD_DEPS)' >> CMakeLists.txt.patch &&\
 echo '' >> CMakeLists.txt.patch &&\
 echo '@@ -120,7 +120,7 @@' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseErlang)' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseDtrace)' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseGo)' >> CMakeLists.txt.patch &&\
 echo '-INCLUDE(FindCouchbaseBreakpad)' >> CMakeLists.txt.patch &&\
 echo '+#INCLUDE(FindCouchbaseBreakpad)' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseFlatbuffers)' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseValgrind)' >> CMakeLists.txt.patch &&\
 echo ' INCLUDE(FindCouchbaseV8)' >> CMakeLists.txt.patch &&\
 patch -p0 < CMakeLists.txt.patch &&\
 echo '+++ couchbase/forestdb/src/arch.h' >> arch.h.patch &&\
 echo '@@ -330,6 +330,10 @@' >> arch.h.patch &&\
 echo '         #define spin_unlock(arg) pthread_spin_unlock(arg)' >> arch.h.patch &&\
 echo '         #define spin_destroy(arg) pthread_spin_destroy(arg)' >> arch.h.patch &&\
 echo '         #define SPIN_INITIALIZER (spin_t)(1)' >> arch.h.patch &&\
 echo '+        #if defined(__s390x__)' >> arch.h.patch &&\
 echo '+            #undef SPIN_INITIALIZER' >> arch.h.patch &&\
 echo '+            #define SPIN_INITIALIZER (spin_t)(0)' >> arch.h.patch &&\
 echo '+        #endif' >> arch.h.patch &&\
 echo '     #endif' >> arch.h.patch &&\
 echo '     #ifndef mutex_t' >> arch.h.patch &&\
 echo '         // mutex' >> arch.h.patch &&\
 patch -p0 < arch.h.patch &&\
 echo '+++ couchbase/couchstore/src/views/bin/couch_view_file_merger.cc' >> couch_view_file_merger.cc.patch &&\
 echo '@@ -37,8 +37,7 @@' >> couch_view_file_merger.cc.patch &&\
 echo "     MERGE_FILE_TYPE_ID_BTREE = 'i'," >> couch_view_file_merger.cc.patch &&\
 echo "     MERGE_FILE_TYPE_MAPREDUCE_VIEW = 'v'," >> couch_view_file_merger.cc.patch &&\
 echo "     MERGE_FILE_TYPE_SPATIAL = 's'" >> couch_view_file_merger.cc.patch &&\
 echo '-} merge_file_type_t;' >> couch_view_file_merger.cc.patch &&\
 echo '-' >> couch_view_file_merger.cc.patch &&\
 echo '+}; typedef unsigned char merge_file_type_t;' >> couch_view_file_merger.cc.patch &&\
 echo '' >> couch_view_file_merger.cc.patch &&\
 echo ' int main(int argc, char *argv[])' >> couch_view_file_merger.cc.patch &&\
 echo ' {' >> couch_view_file_merger.cc.patch &&\
 patch -p0 < couch_view_file_merger.cc.patch &&\
 echo '+++ couchbase/forestdb/utils/debug.cc' >> debug.cc.patch &&\
 echo '@@ -89,6 +89,8 @@' >> debug.cc.patch &&\
 echo '     ucontext_t *u = (ucontext_t *)context;' >> debug.cc.patch &&\
 echo ' #ifdef REG_RIP // Test if the Program Counter is 64 bits' >> debug.cc.patch &&\
 echo '     unsigned char *pc = (unsigned char *)u->uc_mcontext.gregs[REG_RIP];' >> debug.cc.patch &&\
 echo '+#elif __s390x__' >> debug.cc.patch &&\
 echo '+    unsigned char *pc = (unsigned char *)u->uc_mcontext.psw.addr;' >> debug.cc.patch &&\
 echo ' #else // 32 bit machine, PC is stored in %eip register' >> debug.cc.patch &&\
 echo '     unsigned char *pc = (unsigned char *)u->uc_mcontext.gregs[REG_EIP];' >> debug.cc.patch &&\
 echo ' #endif // REG_RIP for 64-bit machines' >> debug.cc.patch &&\
 patch -p0 < debug.cc.patch
RUN echo '+++ couchbase/platform/CMakeLists.txt' >> platformCMakeLists.txt.patch &&\
 echo '@@ -187,7 +187,6 @@' >> platformCMakeLists.txt.patch &&\
 echo '                             src/cbassert.c' >> platformCMakeLists.txt.patch &&\
 echo '                             src/checked_snprintf.cc' >> platformCMakeLists.txt.patch &&\
 echo '                             src/crc32c.cc' >> platformCMakeLists.txt.patch &&\
 echo '-                            src/crc32c_sse4_2.cc' >> platformCMakeLists.txt.patch &&\
 echo '                             src/crc32c_private.h' >> platformCMakeLists.txt.patch &&\
 echo '                             src/getopt.cc' >> platformCMakeLists.txt.patch &&\
 echo '                             src/global_new_replacement.cc' >> platformCMakeLists.txt.patch &&\
 patch -p0 < platformCMakeLists.txt.patch
RUN echo '+++ couchbase/platform/include/platform/crc32c.h' >> crc32c.h.patch &&\
 echo '@@ -39,7 +39,7 @@' >> crc32c.h.patch &&\
 echo ' // To fix will require refactoring to hide the X86 dependencies when' >> crc32c.h.patch &&\
 echo ' // built on another platform.' >> crc32c.h.patch &&\
 echo ' //' >> crc32c.h.patch &&\
 echo '-#if !defined(__x86_64__) && !defined(_M_X64) && !defined(_M_IX86)' >> crc32c.h.patch &&\
 echo '+#if !defined(__x86_64__) && !defined(_M_X64) && !defined(_M_IX86) && !defined(__s390x__)' >> crc32c.h.patch &&\
 echo ' #error "crc32c requires X86 SSE4.2 for hardware acceleration"' >> crc32c.h.patch &&\
 echo ' #endif' >> crc32c.h.patch &&\
 patch -p0 < crc32c.h.patch &&\
 echo '+++ couchbase/platform/src/crc32c.cc' >> crc32c.cc.patch &&\
 echo '@@ -52,6 +52,7 @@' >> crc32c.cc.patch &&\
 echo ' //' >> crc32c.cc.patch &&\
 echo ' ' >> crc32c.cc.patch &&\
 echo ' #include "platform/crc32c.h"' >> crc32c.cc.patch &&\
 echo '+#include <crc32-s390x.h>' >> crc32c.cc.patch &&\
 echo ' #include "crc32c_private.h"' >> crc32c.cc.patch &&\
 echo ' ' >> crc32c.cc.patch &&\
 echo ' #include <stdint.h>' >> crc32c.cc.patch &&\
 echo '@@ -60,7 +61,7 @@' >> crc32c.cc.patch &&\
 echo ' // select header file for cpuid.' >> crc32c.cc.patch &&\
 echo ' #if defined(WIN32)' >> crc32c.cc.patch &&\
 echo ' #include <intrin.h>' >> crc32c.cc.patch &&\
 echo '-#elif defined(__clang__) || defined(__GNUC__)' >> crc32c.cc.patch &&\
 echo '+#elif defined(__clang__) || defined(__GNUC__) && !defined(__s390x__)' >> crc32c.cc.patch &&\
 echo ' #include <cpuid.h>' >> crc32c.cc.patch &&\
 echo ' #endif' >> crc32c.cc.patch &&\
 echo ' ' >> crc32c.cc.patch &&\
 echo '@@ -368,10 +369,10 @@' >> crc32c.cc.patch &&\
 echo ' // If SSE4.2 is available then hardware acceleration is used.' >> crc32c.cc.patch &&\
 echo ' //' >> crc32c.cc.patch &&\
 echo ' crc32c_function setup_crc32c() {' >> crc32c.cc.patch &&\
 echo '-    const uint32_t SSE42 = 0x00100000;' >> crc32c.cc.patch &&\
 echo '+//    const uint32_t SSE42 = 0x00100000;' >> crc32c.cc.patch &&\
 echo ' ' >> crc32c.cc.patch &&\
 echo '     crc32c_function f = crc32c_sw;' >> crc32c.cc.patch &&\
 echo '-' >> crc32c.cc.patch &&\
 echo '+/*' >> crc32c.cc.patch &&\
 echo ' #if defined(WIN32)' >> crc32c.cc.patch &&\
 echo '     std::array<int, 4> registers = {{0,0,0,0}};' >> crc32c.cc.patch &&\
 echo '     __cpuid(registers.data(), 1);' >> crc32c.cc.patch &&\
 echo '@@ -383,7 +384,7 @@' >> crc32c.cc.patch &&\
 echo '     if (registers[2] & SSE42) {' >> crc32c.cc.patch &&\
 echo '         f = crc32c_hw;' >> crc32c.cc.patch &&\
 echo '     }' >> crc32c.cc.patch &&\
 echo '-' >> crc32c.cc.patch &&\
 echo '+*/' >> crc32c.cc.patch &&\
 echo '     return f;' >> crc32c.cc.patch &&\
 echo ' }' >> crc32c.cc.patch &&\
 patch -p0 < crc32c.cc.patch &&\
 echo '+++ couchbase/platform/tests/CMakeLists.txt' >> testsCMakeLists.txt.patch  &&\
 echo '@@ -5,7 +5,7 @@' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(checked_snprintf)' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(cjson)' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(corestore)' >> testsCMakeLists.txt.patch  &&\
 echo '-ADD_SUBDIRECTORY(crc32)' >> testsCMakeLists.txt.patch  &&\
 echo '+#ADD_SUBDIRECTORY(crc32)' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(dirutils)' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(gethrtime)' >> testsCMakeLists.txt.patch  &&\
 echo ' ADD_SUBDIRECTORY(gettimeofday)' >> testsCMakeLists.txt.patch  &&\
 patch -p0 < testsCMakeLists.txt.patch &&\
 echo '+++ couchbase/goproj/src/github.com/couchbase/indexing/secondary/memdb/skiplist/skiplist.go' >> skiplist.go.patch &&\
 echo '@@ -74,12 +74,13 @@' >> skiplist.go.patch &&\
 echo ' 	}' >> skiplist.go.patch &&\
 echo ' ' >> skiplist.go.patch &&\
 echo ' 	if cfg.UseMemoryMgmt {' >> skiplist.go.patch &&\
 echo '-		s.freeNode = func(n *Node) {' >> skiplist.go.patch &&\
 echo '-			if Debug {' >> skiplist.go.patch &&\
 echo '-				debugMarkFree(n)' >> skiplist.go.patch &&\
 echo '-			}' >> skiplist.go.patch &&\
 echo '-			cfg.Free(unsafe.Pointer(n))' >> skiplist.go.patch &&\
 echo '-		}' >> skiplist.go.patch &&\
 echo '+		s.freeNode = func(*Node) {}' >> skiplist.go.patch &&\
 echo '+		//s.freeNode = func(n *Node) {' >> skiplist.go.patch &&\
 echo '+		//	if Debug {' >> skiplist.go.patch &&\
 echo '+		//		debugMarkFree(n)' >> skiplist.go.patch &&\
 echo '+		//	}' >> skiplist.go.patch &&\
 echo '+		//	cfg.Free(unsafe.Pointer(n))' >> skiplist.go.patch &&\
 echo '+		//}' >> skiplist.go.patch &&\
 echo ' 	} else {' >> skiplist.go.patch &&\
 echo ' 		s.freeNode = func(*Node) {}' >> skiplist.go.patch &&\
 echo ' 	}' >> skiplist.go.patch &&\
 patch -p0 < skiplist.go.patch &&\
 echo '+++ couchbase/kv_engine/daemon/subdocument_validators.cc' >> subdocument_validators.cc.patch &&\
 echo '@@ -435,7 +435,7 @@' >> subdocument_validators.cc.patch &&\
 echo ' ' >> subdocument_validators.cc.patch &&\
 echo '     if ((req->request.magic != PROTOCOL_BINARY_REQ) ||' >> subdocument_validators.cc.patch &&\
 echo '         (req->request.keylen == 0) ||' >> subdocument_validators.cc.patch &&\
 echo '-        (req->request.bodylen < minimum_body_len) ||' >> subdocument_validators.cc.patch &&\
 echo '+        (htonl(__bswap_32(req->request.bodylen)) < minimum_body_len) ||' >> subdocument_validators.cc.patch &&\
 echo '         (req->request.datatype != PROTOCOL_BINARY_RAW_BYTES)) {' >> subdocument_validators.cc.patch &&\
 echo '         return PROTOCOL_BINARY_RESPONSE_EINVAL;' >> subdocument_validators.cc.patch &&\
 echo '     }' >> subdocument_validators.cc.patch &&\
 echo '' >> subdocument_validators.cc.patch &&\
 patch -p0 < subdocument_validators.cc.patch &&\
 echo '+++ couchbase/benchmark/src/cycleclock.h' >> cycleclock.h.patch &&\
 echo '@@ -82,6 +82,11 @@' >> cycleclock.h.patch &&\
 echo '   uint64_t low, high;' >> cycleclock.h.patch &&\
 echo '   __asm__ volatile("rdtsc" : "=a"(low), "=d"(high));' >> cycleclock.h.patch &&\
 echo '   return (high << 32) | low;' >> cycleclock.h.patch &&\
 echo '+#elif defined(__s390__) // Covers both s390 and s390x.' >> cycleclock.h.patch &&\
 echo '+  // Return the CPU clock.' >> cycleclock.h.patch &&\
 echo '+  uint64_t tsc;' >> cycleclock.h.patch &&\
 echo '+  asm("stck %0" : "=Q"(tsc) : : "cc");' >> cycleclock.h.patch &&\
 echo '+  return tsc;' >> cycleclock.h.patch &&\
 echo ' #elif defined(__powerpc__) || defined(__ppc__)' >> cycleclock.h.patch &&\
 echo '   // This returns a time-base, which is not always precisely a cycle-count.' >> cycleclock.h.patch &&\
 echo '   int64_t tbl, tbu0, tbu1;' >> cycleclock.h.patch &&\
 patch -p0 < cycleclock.h.patch &&\
 echo '+++ couchbase/platform/include/platform/cacheline_padded.h' >> cacheline_padded.h.patch &&\
 echo '@@ -20,7 +20,7 @@' >> cacheline_padded.h.patch &&\
 echo ' // expect this to be a single cache line (64B on x86-64), but on' >> cacheline_padded.h.patch &&\
 echo ' // Sandybridge (at least) it has been observed that pairs of' >> cacheline_padded.h.patch &&\
 echo ' // cachelines can interfere with each other.' >> cacheline_padded.h.patch &&\
 echo '-#define FALSE_SHARING_RANGE 128' >> cacheline_padded.h.patch &&\
 echo '+#define FALSE_SHARING_RANGE 64' >> cacheline_padded.h.patch &&\
 echo '' >> cacheline_padded.h.patch &&\
 echo ' namespace cb {' >> cacheline_padded.h.patch &&\
patch -p0 < cacheline_padded.h.patch
RUN  echo '+++ couchbase/kv_engine/engines/ep/src/ep_engine.cc' >> ep_engine.cc.patch &&\
 echo '@@ -4353,7 +4353,7 @@' >> ep_engine.cc.patch &&\
 echo '             vb_id);' >> ep_engine.cc.patch &&\
 echo '' >> ep_engine.cc.patch &&\
 echo '         // Get key stats' >> ep_engine.cc.patch &&\
 echo '-        uint16_t keystatus = 0;' >> ep_engine.cc.patch &&\
 echo '+        uint8_t keystatus = 0;' >> ep_engine.cc.patch &&\
 echo '         struct key_stats kstats;' >> ep_engine.cc.patch &&\
 echo '         memset(&kstats, 0, sizeof(key_stats));' >> ep_engine.cc.patch &&\
 echo '         ENGINE_ERROR_CODE rv = kvBucket->getKeyStats(' >> ep_engine.cc.patch &&\
 patch -p0 < ep_engine.cc.patch &&\
 echo '+++ couchbase/kv_engine/engines/ep/src/tagged_ptr.h' >> tagged_ptr.h.patch &&\
 echo '@@ -19,7 +19,7 @@' >> tagged_ptr.h.patch &&\
 echo '' >> tagged_ptr.h.patch &&\
 echo ' #include <memory>' >> tagged_ptr.h.patch &&\
 echo '' >> tagged_ptr.h.patch &&\
 echo '-#if !__x86_64__ && !_M_X64' >> tagged_ptr.h.patch &&\
 echo '+#if !__x86_64__ && !_M_X64 && !__s390x__' >> tagged_ptr.h.patch &&\
 echo ' #error "TaggedPtr is x64 specific code.  Not tested on other architectures"' >> tagged_ptr.h.patch &&\
 echo ' #endif' >> tagged_ptr.h.patch &&\
 patch -p0 < tagged_ptr.h.patch &&\
 echo '+++ couchbase/tlm/cmake/Modules/CBDownloadDeps.cmake' >> CBDownloadDeps.cmake.patch &&\
 echo '@@ -269,7 +269,11 @@' >> CBDownloadDeps.cmake.patch &&\
 echo '       SET (_gofile "go${GOVERSION}.freebsd-amd64.tar.gz")' >> CBDownloadDeps.cmake.patch &&\
 echo '     ELSE ()' >> CBDownloadDeps.cmake.patch &&\
 echo '       # Presumed Linux' >> CBDownloadDeps.cmake.patch &&\
 echo '-      SET (_gofile "go${GOVERSION}.linux-amd64.tar.gz")' >> CBDownloadDeps.cmake.patch &&\
 echo '+      IF (_arch STREQUAL "s390x")' >> CBDownloadDeps.cmake.patch &&\
 echo '+        SET (_gofile "go${GOVERSION}.linux-s390x.tar.gz")' >> CBDownloadDeps.cmake.patch &&\
 echo '+      ELSE ()' >> CBDownloadDeps.cmake.patch &&\
 echo '+        SET (_gofile "go${GOVERSION}.linux-amd64.tar.gz")' >> CBDownloadDeps.cmake.patch &&\
 echo '+      ENDIF ()' >> CBDownloadDeps.cmake.patch &&\
 echo '     ENDIF ()' >> CBDownloadDeps.cmake.patch &&\
 echo '     SET (_cachefile "${CB_DOWNLOAD_DEPS_CACHE}/${_gofile}")' >> CBDownloadDeps.cmake.patch &&\
 echo '     IF (NOT EXISTS "${_cachefile}")' >> CBDownloadDeps.cmake.patch &&\
 patch -p0 < CBDownloadDeps.cmake.patch &&\
 echo '+++ couchbase/kv_engine/engines/ep/tests/ep_testsuite_xdcr.cc' >> ep_testsuite_xdcr.cc.patch &&\
 echo '@@ -2384,7 +2384,7 @@' >> ep_testsuite_xdcr.cc.patch &&\
 echo '     itemMeta.flags = 0xdeadbeef;' >> ep_testsuite_xdcr.cc.patch &&\
 echo '' >> ep_testsuite_xdcr.cc.patch &&\
 echo '     // Watson (4.6) accepts valid encodings, but ignores them' >> ep_testsuite_xdcr.cc.patch &&\
 echo '-    std::vector<char> junkMeta = {-2,-1,2,3};' >> ep_testsuite_xdcr.cc.patch &&\
 echo '+    std::vector<char> junkMeta = {char(-2),char(-1),2,3};' >> ep_testsuite_xdcr.cc.patch &&\
 echo '' >> ep_testsuite_xdcr.cc.patch &&\
 echo '     int force = 0;' >> ep_testsuite_xdcr.cc.patch &&\
 patch -p0 < ep_testsuite_xdcr.cc.patch &&\
 echo '+++ couchbase/platform/include/platform/n_byte_integer.h' >> n_byte_integer.h.patch &&\
 echo '@@ -98,12 +98,20 @@' >> n_byte_integer.h.patch &&\
 echo '     /// @return the current value as a uint64_t' >> n_byte_integer.h.patch &&\
 echo '     uint64_t load() const {' >> n_byte_integer.h.patch &&\
 echo '         uint64_t value = 0;' >> n_byte_integer.h.patch &&\
 echo '+#if __s390x__' >> n_byte_integer.h.patch &&\
 echo '+	std::copy_n(counter.begin(), N, ((8-N)+reinterpret_cast<uint8_t*>(&value)));' >> n_byte_integer.h.patch &&\
 echo '+#else' >> n_byte_integer.h.patch &&\
 echo '         std::copy_n(counter.begin(), N, reinterpret_cast<uint8_t*>(&value));' >> n_byte_integer.h.patch &&\
 echo '+#endif' >> n_byte_integer.h.patch &&\
 echo '         return value;' >> n_byte_integer.h.patch &&\
 echo '     }' >> n_byte_integer.h.patch &&\
 echo ' ' >> n_byte_integer.h.patch &&\
 echo '     void store(uint64_t value) {' >> n_byte_integer.h.patch &&\
 echo '+#if __s390x__' >> n_byte_integer.h.patch &&\
 echo '+        std::copy_n((reinterpret_cast<uint8_t*>(&value)+(8-N)), N, counter.begin());' >> n_byte_integer.h.patch &&\
 echo '+#else' >> n_byte_integer.h.patch &&\
 echo '         std::copy_n(reinterpret_cast<uint8_t*>(&value), N, counter.begin());' >> n_byte_integer.h.patch &&\
 echo '+#endif' >> n_byte_integer.h.patch &&\
 echo '     }' >> n_byte_integer.h.patch &&\
 echo ' ' >> n_byte_integer.h.patch &&\
 echo '     /// The current value of the n-byte integer' >> n_byte_integer.h.patch &&\
 patch -p0 < n_byte_integer.h.patch &&\
 echo '+++ couchbase/couchstore/tests/views/index_headers.cc' > index_headers.cc.patch &&\
 echo '@@ -343,7 +343,7 @@' >> index_headers.cc.patch &&\
 echo '     size_t header_bin2_size = 0;' >> index_headers.cc.patch &&\
 echo '     char *header_bin3 = NULL;' >> index_headers.cc.patch &&\
 echo '     size_t header_bin3_size = 0;' >> index_headers.cc.patch &&\
 echo '-' >> index_headers.cc.patch &&\
 echo '+#if !__s390x__' >> index_headers.cc.patch &&\
 echo '     unsigned char header_bin[] = {' >> index_headers.cc.patch &&\
 echo '         5,226,251,160,170,107,207,39,248,218,139,62,137,58,95,46,204,10,12,1,0,64,0,' >> index_headers.cc.patch &&\
 echo '         254,1,0,218,1,0,0,136,5,1,4,0,136,254,127,0,218,127,0,8,0,83,119,9,1,254,128,' >> index_headers.cc.patch &&\
 echo '@@ -361,7 +361,28 @@' >> index_headers.cc.patch &&\
 echo '         0,254,154,0,46,154,0,112,1,0,4,0,5,0,10,0,60,0,62,0,2,0,11,0,15,0,2,0,58,0,' >> index_headers.cc.patch &&\
 echo '         61,0,2,0,15,0,58,105,173,44,0,0,4,197,0,63,0,0,0,0,4,197' >> index_headers.cc.patch &&\
 echo '     };' >> index_headers.cc.patch &&\
 echo '-' >> index_headers.cc.patch &&\
 echo '+#else' >> index_headers.cc.patch &&\
 echo '+    unsigned char header_bin[] = {' >> index_headers.cc.patch &&\
 echo '+        5,226,251,160,170,107,207,39,248,218,139,62,137,58,95,46,204,10,12,1,0,64,0,' >> index_headers.cc.patch &&\
 echo '+        254,1,0,218,1,0,0,136,5,1,4,0,136,254,127,0,218,127,0,8,0,83,119,9,1,254,128,' >> index_headers.cc.patch &&\
 echo '+        0,222,128,0,0,36,5,121,20,136,0,0,58,0,1,1,11,12,4,197,0,2,13,8,0,3,13,' >> index_headers.cc.patch &&\
 echo '+        8,0,4,13,8,0,5,13,8,0,6,13,8,0,7,13,8,0,8,13,8,0,9,13,8,0,10,' >> index_headers.cc.patch &&\
 echo '+        13,8,0,12,13,8,0,13,13,8,0,14,13,8,0,16,13,8,0,17,13,8,0,18,' >> index_headers.cc.patch &&\
 echo '+        13,8,0,19,13,8,0,20,13,8,0,21,13,8,0,22,13,8,0,23,13,8,0,24,' >> index_headers.cc.patch &&\
 echo '+        13,8,0,25,13,8,0,26,13,8,0,27,13,8,0,28,13,8,0,29,13,8,0,30,' >> index_headers.cc.patch &&\
 echo '+        13,8,0,31,13,8,0,32,13,8,0,33,13,8,0,34,13,8,0,35,13,8,37,19,' >> index_headers.cc.patch &&\
 echo '+        12,4,197,0,37,13,16,0,38,13,8,0,39,13,8,0,40,13,8,0,41,13,8,0,' >> index_headers.cc.patch &&\
 echo '+        42,13,8,0,43,13,8,0,44,13,8,0,45,13,8,0,46,13,8,0,47,13,8,0,' >> index_headers.cc.patch &&\
 echo '+        48,13,8,0,49,13,8,0,50,13,8,0,51,13,8,0,52,13,8,0,53,13,8,0,' >> index_headers.cc.patch &&\
 echo '+        54,13,8,0,55,13,8,0,56,13,8,0,57,13,8,0,59,13,8,0,60,13,8,0,' >> index_headers.cc.patch &&\
 echo '+        62,13,8,64,145,0,0,0,24,174,99,0,0,0,19,159,140,0,0,1,49,254,101,3,' >> index_headers.cc.patch &&\
 echo '+        226,101,3,0,255,13,1,32,2,0,152,0,0,0,44,71,93,1,148,4,152,106,254,148,' >> index_headers.cc.patch &&\
 echo '+        0,254,148,0,5,148,24,0,5,55,56,49,52,52,5,154,8,63,200,207,1,154,4,129,' >> index_headers.cc.patch &&\
 echo '+        243,254,154,0,254,154,0,46,154,0,112,1,0,4,0,5,0,10,0,60,0,62,0,2,' >> index_headers.cc.patch &&\
 echo '+        0,11,0,15,0,2,0,58,0,61,0,2,0,15,0,58,105,173,44,0,0,4,197,0,' >> index_headers.cc.patch &&\
 echo '+        63,0,0,0,0,4,197' >> index_headers.cc.patch &&\
 echo '+    };' >> index_headers.cc.patch &&\
 echo '+#endif' >> index_headers.cc.patch &&\
 echo '     fprintf(stderr, "Decoding an index header v1...\\n");' >> index_headers.cc.patch &&\
 echo '     header = test_index_header_decoding_v1((const char*)header_bin, sizeof(header_bin));' >> index_headers.cc.patch &&\
 echo ' ' >> index_headers.cc.patch &&\
 echo '@@ -395,7 +416,7 @@' >> index_headers.cc.patch &&\
 echo '     size_t header_bin2_size = 0;' >> index_headers.cc.patch &&\
 echo '     char *header_bin3 = NULL;' >> index_headers.cc.patch &&\
 echo '     size_t header_bin3_size = 0;' >> index_headers.cc.patch &&\
 echo '-' >> index_headers.cc.patch &&\
 echo '+#if !__s390x__' >> index_headers.cc.patch &&\
 echo '     unsigned char header_bin[] = {' >> index_headers.cc.patch &&\
 echo '         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,237,14,12,2,0,32,0,254,1,0,234,1,0,12,1,32,0,' >> index_headers.cc.patch &&\
 echo '         24,254,127,0,234,127,0,16,0,144,0,64,34,254,128,0,238,128,0,12,0,0,32,4,61,' >> index_headers.cc.patch &&\
 echo '@@ -421,7 +442,38 @@' >> index_headers.cc.patch &&\
 echo '         92,62,36,0,0,27,58,36,0,129,120,62,36,0,0,28,54,36,0,133,148,62,36,0,0,29,58,' >> index_headers.cc.patch &&\
 echo '         36,0,129,176,62,36,0,0,30,58,36,0,129,204,62,36,0,0,31,58,36,0,0,193' >> index_headers.cc.patch &&\
 echo '     };' >> index_headers.cc.patch &&\
 echo '-' >> index_headers.cc.patch &&\
 echo '+#else' >> index_headers.cc.patch &&\
 echo '+    unsigned char header_bin[] = {' >> index_headers.cc.patch &&\
 echo '+        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,237,14,12,2,0,32,0,254,' >> index_headers.cc.patch &&\
 echo '+        1,0,234,1,0,12,1,32,0,24,254,127,0,234,127,0,16,0,144,0,64,34,254,128,' >> index_headers.cc.patch &&\
 echo '+        0,238,128,0,12,0,0,32,4,61,130,0,1,5,140,8,1,0,2,5,8,8,4,0,' >> index_headers.cc.patch &&\
 echo '+        3,5,8,8,9,0,4,5,8,8,16,0,5,5,8,8,25,0,6,5,8,8,36,0,' >> index_headers.cc.patch &&\
 echo '+        7,5,8,8,49,0,8,5,8,8,64,0,9,5,8,8,81,0,10,5,8,8,100,0,' >> index_headers.cc.patch &&\
 echo '+        11,5,8,8,121,0,12,5,8,8,144,0,13,5,8,8,169,0,14,5,8,8,196,0,' >> index_headers.cc.patch &&\
 echo '+        15,5,8,8,225,0,16,1,8,12,1,0,0,17,5,8,8,33,0,18,5,8,8,68,' >> index_headers.cc.patch &&\
 echo '+        0,19,5,8,8,105,0,20,5,8,8,144,0,21,5,8,8,185,0,22,5,8,8,228,' >> index_headers.cc.patch &&\
 echo '+        0,23,1,8,4,2,17,41,196,12,2,64,0,25,5,16,8,113,0,26,5,8,8,164,' >> index_headers.cc.patch &&\
 echo '+        0,27,5,8,8,217,0,28,1,8,12,3,16,0,29,5,8,8,73,0,30,5,8,8,' >> index_headers.cc.patch &&\
 echo '+        132,0,31,5,8,0,193,9,112,4,0,123,1,14,32,2,55,114,101,100,118,97,108,2,' >> index_headers.cc.patch &&\
 echo '+        9,125,4,9,41,1,21,4,3,21,9,21,0,50,9,21,4,13,128,1,21,4,34,197,' >> index_headers.cc.patch &&\
 echo '+        9,21,52,51,0,0,1,0,5,0,2,0,14,0,28,0,1,37,62,16,1,0,28,0,' >> index_headers.cc.patch &&\
 echo '+        2,53,62,17,102,65,234,32,2,97,117,117,105,100,49,50,51,1,66,1,1,28,97,110,' >> index_headers.cc.patch &&\
 echo '+        111,116,104,101,114,49,1,12,5,1,0,1,66,36,0,0,1,58,36,0,33,160,62,72,' >> index_headers.cc.patch &&\
 echo '+        0,0,2,58,36,0,33,188,62,36,0,0,3,58,36,0,33,216,62,36,0,0,4,58,' >> index_headers.cc.patch &&\
 echo '+        36,0,33,244,62,36,0,0,5,58,36,0,65,16,62,36,0,0,6,58,36,0,65,44,' >> index_headers.cc.patch &&\
 echo '+        62,36,0,0,7,58,36,0,65,72,62,36,0,0,8,58,36,0,65,100,62,36,0,0,' >> index_headers.cc.patch &&\
 echo '+        9,58,36,0,65,128,62,36,0,0,10,58,36,0,65,156,62,36,0,0,11,58,36,0,' >> index_headers.cc.patch &&\
 echo '+        8,121,0,12,66,36,0,0,12,58,36,0,65,212,62,72,0,0,13,58,36,0,65,240,' >> index_headers.cc.patch &&\
 echo '+        62,36,0,0,14,58,36,0,8,196,0,15,66,36,0,0,15,58,36,0,97,40,62,72,' >> index_headers.cc.patch &&\
 echo '+        0,0,16,54,36,0,101,68,62,36,0,0,17,58,36,0,97,96,62,36,0,0,18,58,' >> index_headers.cc.patch &&\
 echo '+        36,0,97,124,62,36,0,0,19,58,36,0,97,152,62,36,0,0,20,58,36,0,97,180,' >> index_headers.cc.patch &&\
 echo '+        62,36,0,0,21,58,36,0,97,208,62,36,0,0,22,58,36,0,8,228,0,23,66,36,' >> index_headers.cc.patch &&\
 echo '+        0,0,23,54,36,0,0,2,129,8,62,72,0,0,24,58,36,0,129,36,62,36,0,0,' >> index_headers.cc.patch &&\
 echo '+        25,58,36,0,129,64,62,36,0,0,26,58,36,0,129,92,62,36,0,0,27,58,36,0,' >> index_headers.cc.patch &&\
 echo '+        129,120,62,36,0,0,28,54,36,0,133,148,62,36,0,0,29,58,36,0,129,176,62,36,' >> index_headers.cc.patch &&\
 echo '+        0,0,30,58,36,0,129,204,62,36,0,0,31,58,36,0,0,193' >> index_headers.cc.patch &&\
 echo '+    };' >> index_headers.cc.patch &&\
 echo '+#endif' >> index_headers.cc.patch &&\
 echo '     fprintf(stderr, "Decoding an index header v2...\\n");' >> index_headers.cc.patch &&\
 echo '     header = test_index_header_decoding_v2(' >> index_headers.cc.patch &&\
 echo '         (const char*)header_bin, sizeof(header_bin));' >> index_headers.cc.patch &&\
 patch -p0 < index_headers.cc.patch &&\
 echo '+++ couchbase/couchstore/tests/views/spatial.cc' >> spatial.cc.patch &&\
 echo '@@ -280,6 +280,7 @@' >> spatial.cc.patch &&\
 echo '     char encoded[66];' >> spatial.cc.patch &&\
 echo '     double mbb[] = {6.3, 18.7};' >> spatial.cc.patch &&\
 echo '     double mbb2[] = {1.0, 3.0, 30.33, 31.33, 15.4, 138.7, 7.8, 7.8};' >> spatial.cc.patch &&\
 echo '+#if !__s390x__' >> spatial.cc.patch &&\
 echo '     unsigned char expected[] = {' >> spatial.cc.patch &&\
 echo '         0x00, 0x02, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x19, 0x40,' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x33, 0xb3, 0x32, 0x40' >> spatial.cc.patch &&\
 echo '@@ -293,7 +294,22 @@' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x1f, 0x40, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x1f, 0x40' >> spatial.cc.patch &&\
 echo '     };' >> spatial.cc.patch &&\
 echo '-' >> spatial.cc.patch &&\
 echo '+#else' >> spatial.cc.patch &&\
 echo '+    unsigned char expected[] = {' >> spatial.cc.patch &&\
 echo '+        0x00, 0x02, 0x40, 0x19, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+        0x33, 0x33, 0x40, 0x32, 0xb3, 0x33, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+    };' >> spatial.cc.patch &&\
 echo '+    unsigned char expected2[] = {' >> spatial.cc.patch &&\
 echo '+        0x00, 0x08, 0x3f, 0xf0, 0x00, 0x00, 0x00, 0x00,' >> spatial.cc.patch &&\
 echo '+        0x00, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00,' >> spatial.cc.patch &&\
 echo '+        0x00, 0x00, 0x40, 0x3e, 0x54, 0x7a, 0xe1, 0x47,' >> spatial.cc.patch &&\
 echo '+        0xae, 0x14, 0x40, 0x3f, 0x54, 0x7a, 0xe1, 0x47,' >> spatial.cc.patch &&\
 echo '+        0xae, 0x14, 0x40, 0x2e, 0xcc, 0xcc, 0xcc, 0xcc,' >> spatial.cc.patch &&\
 echo '+        0xcc, 0xcd, 0x40, 0x61, 0x56, 0x66, 0x66, 0x66,' >> spatial.cc.patch &&\
 echo '+        0x66, 0x66, 0x40, 0x1f, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+        0x33, 0x33, 0x40, 0x1f, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33' >> spatial.cc.patch &&\
 echo '+    };' >> spatial.cc.patch &&\
 echo '+#endif' >> spatial.cc.patch &&\
 echo '     fprintf(stderr, "Running encode spatial key tests\\n");' >> spatial.cc.patch &&\
 echo ' ' >> spatial.cc.patch &&\
 echo '     mbb_struct.mbb = mbb;' >> spatial.cc.patch &&\
 echo '@@ -325,6 +341,7 @@' >> spatial.cc.patch &&\
 echo ' void test_decode_spatial_key()' >> spatial.cc.patch &&\
 echo ' {' >> spatial.cc.patch &&\
 echo '     sized_mbb_t decoded;' >> spatial.cc.patch &&\
 echo '+#if !__s390x__' >> spatial.cc.patch &&\
 echo '     unsigned char mbb[] = {' >> spatial.cc.patch &&\
 echo '         0x00, 0x02, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x19, 0x40,' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x33, 0xb3, 0x32, 0x40' >> spatial.cc.patch &&\
 echo '@@ -338,6 +355,24 @@' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x1f, 0x40, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '         0x33, 0x33, 0x33, 0x33, 0x1f, 0x40' >> spatial.cc.patch &&\
 echo '     };' >> spatial.cc.patch &&\
 echo '+#else' >> spatial.cc.patch &&\
 echo '+    unsigned char mbb[] = {' >> spatial.cc.patch &&\
 echo '+       0x00, 0x02, 0x40, 0x19, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+       0x33, 0x33, 0x40, 0x32, 0xb3, 0x33, 0x33, 0x33, 0x33, 0x33' >> spatial.cc.patch &&\
 echo '+    };' >> spatial.cc.patch &&\
 echo '+    unsigned char mbb2[] = {' >> spatial.cc.patch &&\
 echo '+       0x00, 0x08, 0x3f, 0xf0, 0x00, 0x00, 0x00, 0x00,' >> spatial.cc.patch &&\
 echo '+       0x00, 0x00, 0x40, 0x08, 0x00, 0x00, 0x00, 0x00,' >> spatial.cc.patch &&\
 echo '+       0x00, 0x00, 0x40, 0x3e, 0x54, 0x7a, 0xe1, 0x47,' >> spatial.cc.patch &&\
 echo '+       0xae, 0x14, 0x40, 0x3f, 0x54, 0x7a, 0xe1, 0x47,' >> spatial.cc.patch &&\
 echo '+       0xae, 0x14, 0x40, 0x2e, 0xcc, 0xcc, 0xcc, 0xcc,' >> spatial.cc.patch &&\
 echo '+       0xcc, 0xcd, 0x40, 0x61, 0x56, 0x66, 0x66, 0x66,' >> spatial.cc.patch &&\
 echo '+       0x66, 0x66, 0x40, 0x1f, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+       0x33, 0x33, 0x40, 0x1f, 0x33, 0x33, 0x33, 0x33,' >> spatial.cc.patch &&\
 echo '+       0x33, 0x33' >> spatial.cc.patch &&\
 echo '+    };' >> spatial.cc.patch &&\
 echo '+' >> spatial.cc.patch &&\
 echo '+#endif' >> spatial.cc.patch &&\
 echo '     double expected[] = {6.3, 18.7};' >> spatial.cc.patch &&\
 echo '     double expected2[] = {1.0, 3.0, 30.33, 31.33, 15.4, 138.7, 7.8, 7.8};' >> spatial.cc.patch &&\
 patch -p0 < spatial.cc.patch
RUN  echo '+++ couchbase/tlm/cmake/Modules/FindCouchbaseNlohmannJson.cmake' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo '@@ -3,7 +3,7 @@' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo ' #' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo ' #  NLOHMANN_JSON_INCLUDE_DIR' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo ' ' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo '-SET(_nhlomann_json_exploded ${CMAKE_BINARY_DIR}/tlm/deps/json.exploded)' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo '+SET(_nhlomann_json_exploded /tmp/source/json/)' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo ' ' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo ' FIND_PATH(NLOHMANN_JSON_INCLUDE_DIR nlohmann/json.hpp' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 echo '           HINTS' >> FindCouchbaseNlohmannJson.cmake.patch &&\
 patch -p0 < FindCouchbaseNlohmannJson.cmake.patch &&\
 echo '+++ couchbase/tlm/cmake/Modules/FindCouchbaseLibevent.cmake' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '@@ -44,7 +44,10 @@' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '     get_filename_component(${_dirname} ${resolved} DIRECTORY)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '   endif ()' >> FindCouchbaseLibevent.cmake.patch &&\
 echo ' endmacro(get_directory _dirname filename)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '-' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '+set(LIBEVENT_INCLUDE_DIR /usr/include)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '+set(LIBEVENT_EXTRA_LIB /usr/lib/s390x-linux-gnu/libevent_extra.so)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '+set(LIBEVENT_CORE_LIB /usr/lib/s390x-linux-gnu/libevent_core.so)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo '+set(LIBEVENT_THREAD_LIB /usr/lib/s390x-linux-gnu/libevent_pthreads.so)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo ' set(_libevent_exploded ${CMAKE_BINARY_DIR}/tlm/deps/libevent.exploded)' >> FindCouchbaseLibevent.cmake.patch &&\
 echo ' set(_libevent_library_dir ${CMAKE_INSTALL_PREFIX})' >> FindCouchbaseLibevent.cmake.patch &&\
 patch -p0 < FindCouchbaseLibevent.cmake.patch

# Replace Boltdb
WORKDIR $SOURCE_ROOT/couchbase/godeps/src/github.com/
RUN mv boltdb boltdb_ORIG &&\
 mkdir boltdb
WORKDIR $SOURCE_ROOT/couchbase/godeps/src/github.com/boltdb
RUN git clone https://github.com/boltdb/bolt.git
WORKDIR $SOURCE_ROOT/couchbase/godeps/src/github.com/boltdb/bolt
RUN git checkout v1.3.0

# Install s390x crc32 support
WORKDIR $SOURCE_ROOT
RUN git clone https://github.com/linux-on-ibm-z/crc32-s390x.git
WORKDIR $SOURCE_ROOT/crc32-s390x
ENV CC /usr/bin/gcc
RUN make &&\
 cp crc32-s390x.h /usr/local/include/ &&\
 cp libcrc32_s390x.a /usr/local/lib/

# Update the sys package
WORKDIR $SOURCE_ROOT/couchbase/godeps/src/golang.org/x/
RUN mv sys sys_ORIG &&\
 git clone https://github.com/golang/sys.git

# Install go tool yacc
ENV CB_MULTI_GO 0
ENV GOPATH /root/go
RUN go get -u golang.org/x/tools/cmd/goyacc &&\
 cp $HOME/go/bin/goyacc /usr/lib/go-1.10/pkg/tool/linux_s390x/ &&\
 chown root:root /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc &&\
 chmod -f 755 /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc &&\
 ln -sf /usr/lib/go-1.10/pkg/tool/linux_s390x/goyacc /usr/lib/go-1.10/pkg/tool/linux_s390x/yacc

# Build Couchbase
WORKDIR $SOURCE_ROOT/couchbase
RUN echo ${PATH}
RUN echo ${LD_LIBRARY_PATH}
RUN ldconfig
RUN make
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
