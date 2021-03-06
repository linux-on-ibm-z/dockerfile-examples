# © Copyright IBM Corporation 2019, 2021.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for ScyllaDB version 4.4.1 #########
#
# This Dockerfile builds a basic installation of ScyllaDB.
#
# ScyllaDB is a high performance distributed NoSQL database.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build --build-arg TARGET=<target_value> -t <image_name> .
#
# To start ScyllaDB Server run the below command:
# Replace the following parameters in the command below:
#   - <container_name> : Name of the container
#   - <image_name>     : Name of the ScyllaDB image
#   - <ip_address>     : IP address of the host machine running Scylla server.
#
# docker run -dt --name <container_name> --network host <image_name> \
#   /opt/scylladb/scylla/libexec/scylla \
#   --options-file /opt/scylladb/scylla/conf/scylla.yaml \
#   --max-io-requests 65 \
#   --listen-address <ip_address> \
#   --rpc-address <ip_address> \
#   --seed-provider-parameters seeds=<ip_address>
#   --api-address <ip_address>
#
# Reference :
# http://www.scylladb.com
#
#######################################################################

# Base Image
FROM ubuntu:18.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=/usr/local/bin:/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:$LD_RUN_PATH
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV CC=/usr/local/bin/gcc
ENV CXX=/usr/local/bin/g++
ENV ver=1.0
ENV URL=https
ENV LC_ALL=C

ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ScyllaDB/4.4.1/patch/"

ARG TARGET=native

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gcc g++ \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libaio-dev \
    systemtap-sdt-dev lksctp-tools xfsprogs \
    libyaml-dev openssl libevent-dev \
    libmpfr-dev libmpcdec-dev \
    libssl-dev libsystemd-dev \
    libsctp-dev libsnappy-dev libpciaccess-dev libxml2-dev xfslibs-dev \
    libgnutls28-dev libiconv-hook-dev liblzma-dev libbz2-dev \
    libxslt-dev libjsoncpp-dev libc-ares-dev \
    libprotobuf-dev protobuf-compiler libcrypto++-dev \
    libtool perl ant libffi-dev \
    automake make git maven ninja-build \
    unzip bzip2 wget curl xz-utils texinfo \
    diffutils liblua5.3-dev libnuma-dev libunistring-dev \
    pigz ragel rapidjson-dev stow patch locales valgrind libudev-dev \
    net-tools ethtool gnutls-bin patchelf util-linux \
    gawk gzip \
# packaging scripts expect lsblk to be in /usr/bin/
  && ln -s /bin/lsblk /usr/bin/ \
#######################################################################
  && ver=2.36 \
  && cd "$SOURCE_ROOT" \
  && URL="http://ftpmirror.gnu.org/binutils/binutils-${ver}.tar.gz" \
  && curl -sSL $URL | tar xzf - \
  && cd binutils-${ver} \
  && mkdir objdir \
  && cd objdir \
  && CC=/usr/bin/gcc ../configure --prefix=/usr/local --build=s390x-linux-gnu \
  && make -j 8 \
  && make install \
#######################################################################
  && ver=10.2.0 \
  && cd "$SOURCE_ROOT" \
  && URL="https://ftp.gnu.org/gnu/gcc/gcc-${ver}/gcc-${ver}.tar.gz" \
  && curl -sSL $URL | tar xzf - \
  && cd gcc-${ver} \
  && ./contrib/download_prerequisites \
  && mkdir objdir \
  && cd objdir \
  && CC=/usr/bin/gcc CXX=/usr/bin/g++ ../configure --enable-languages=c,c++ --prefix=/usr/local \
    --enable-shared --enable-threads=posix \
    --disable-multilib --disable-libmpx \
    --with-system-zlib --with-long-double-128 --with-arch=zEC12 \
    --disable-libphobos --disable-werror \
    --build=s390x-linux-gnu --host=s390x-linux-gnu --target=s390x-linux-gnu \
  && make -j 8 bootstrap \
  && make install \
#######################################################################
  && ver=3.8.6 \
  && cd "$SOURCE_ROOT" \
  && URL="https://www.python.org/ftp/python/${ver}/Python-${ver}.tgz" \
  && curl -sSL $URL | tar xzf - \
  && cd Python-${ver} \
  && ./configure \
  && make \
  && make install \
  && pip3 install --user --upgrade pip \
  && pip3 install --user pyparsing colorama pyyaml cassandra-driver boto3 requests pyte \
#######################################################################
  && ver=3.17.4 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/Kitware/CMake/releases/download/v${ver}/cmake-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd cmake-${ver} \
  && ./bootstrap \
  && make \
  && make install \
#######################################################################
  && ver=1.9.3 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/lz4/lz4/archive/v${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd lz4-${ver} \
  && make install \
#######################################################################
  && ver=1.4.5 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/facebook/zstd/releases/download/v${ver}/zstd-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd zstd-${ver} \
  && curl -sSL ${PATCH_URL}/zstd.diff | patch -p1 \
  && cd lib \
  && make \
  && make install \
#######################################################################
  && ver=0.8.0 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/Cyan4973/xxHash/archive/v${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd xxHash-${ver} \
  && make install \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && mkdir cryptopp \
  && cd cryptopp \
  && curl -ksSLO https://github.com/weidai11/cryptopp/archive/refs/tags/CRYPTOPP_8_2_0.zip \
  && unzip CRYPTOPP_8_2_0.zip \
  && cd cryptopp-CRYPTOPP_8_2_0 \
  && CXXFLAGS="-std=c++11 -g -O2" make \
  && make install \
#######################################################################
  && ver=3.5.2 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/antlr/antlr3/archive/${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd antlr3-${ver} \
  && curl -sSL ${PATCH_URL}/antlr3.diff | patch -p1 \
  && cp runtime/Cpp/include/antlr3* /usr/local/include/ \
  && cd antlr-complete \
  && MAVEN_OPTS="-Xmx4G" mvn \
  && echo 'java -cp '"$(pwd)"'/target/antlr-complete-3.5.2.jar org.antlr.Tool $@' | tee /usr/local/bin/antlr3 \
  && chmod +x /usr/local/bin/antlr3 \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && URL=https://boostorg.jfrog.io/artifactory/main/release/1.74.0/source/boost_1_74_0.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd boost_1_74_0 \
  && sed -i 's/array\.hpp/array_wrapper.hpp/g' boost/numeric/ublas/matrix.hpp \
  && sed -i 's/array\.hpp/array_wrapper.hpp/g' boost/numeric/ublas/storage.hpp \
  && ./bootstrap.sh \
  && ./b2 toolset=gcc variant=release link=shared runtime-link=shared threading=multi --without-python install \
#######################################################################
  && ver=0.13.0 \
  && cd "$SOURCE_ROOT" \
  && URL=http://archive.apache.org/dist/thrift/${ver}/thrift-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd thrift-${ver} \
  && ./configure --without-java --without-lua --without-go --disable-tests --disable-tutorial \
  && make -j 2 \
  && make install \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && git clone https://github.com/fmtlib/fmt.git \
  && cd fmt \
  && git checkout 6.2.1 \
  && mkdir build \
  && cd build \
  && /usr/local/bin/cmake -DFMT_TEST=OFF -DCMAKE_CXX_STANDARD=17 .. \
  && make \
  && make install \
#######################################################################
  && ver=0.6.3 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd yaml-cpp-yaml-cpp-${ver} \
  && mkdir build \
  && cd build \
  && /usr/local/bin/cmake .. \
  && make \
  && make install \
#######################################################################
  && ver=2.4.1 \
  && cd "$SOURCE_ROOT" \
  && URL=https://download.open-mpi.org/release/hwloc/v2.4/hwloc-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd hwloc-${ver} \
  && ./configure \
  && make install \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && git clone https://github.com/scylladb/scylla.git \
  && cd scylla \
  && git checkout scylla-4.4.1 \
  && git submodule update --init --force --recursive \
  && curl -sSL ${PATCH_URL}/seastar.diff | patch -d seastar -p1 \
  && curl -sSL ${PATCH_URL}/scylla.diff | patch -p1  \
  && sed -i 's/boost\/function_output_iterator\.hpp/boost\/iterator\/function_output_iterator\.hpp/g' \
    /usr/local/include/boost/signals2/detail/null_output_iterator.hpp \
  && ./configure.py --mode=release --target=${TARGET} --debuginfo=0 \
  --cflags="-I/usr/local/include -I/usr/local/include/boost -L/usr/local/lib -L/usr/local/lib64 -fcoroutines " \
    --ldflags="-Wl,--build-id=sha1" --static-thrift \
    --compiler="${CXX}" --c-compiler="${CC}"\
  && ninja build -j 2 \
  && mkdir -p /opt/scylladb/dependencies/ \
  && (cd /opt/scylladb/dependencies/ && curl -L -O https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-s390x.tar.gz) \
  && ln -s /usr/local/bin/hwloc-* /usr/bin/ \
  && ln -s /bin/gzip /usr/bin/gzip \
  && ln -s /sbin/ifconfig /usr/sbin/ifconfig \
  && ln -s /sbin/ethtool /usr/sbin/ethtool \
  && ln -s /bin/netstat /usr/bin/netstat \
  && mkdir -p /lib64 \
  && ln -s /lib/s390x-linux-gnu/libthread_db-1.0.so /lib64/libthread_db-1.0.so \
  && mkdir -p /etc/crypto-policies/back-ends \
  && touch /etc/crypto-policies/back-ends/gnutls.config \
  && ninja dist-server-tar \
#######################################################################
  && rm -rf $SOURCE_ROOT/antlr3-3.5.2 \
      $SOURCE_ROOT/boost_1_74_0 \
      $SOURCE_ROOT/thrift-0.13.0 \
      $SOURCE_ROOT/yaml-cpp-yaml-cpp-0.6.3 \
      $SOURCE_ROOT/cmake-3.17.4 \
      $SOURCE_ROOT/fmt \
      $SOURCE_ROOT/Python-3.8.6 \
      $SOURCE_ROOT/lz4-1.9.3 \
      $SOURCE_ROOT/zstd-1.4.5 \
      $SOURCE_ROOT/cryptopp \
      $SOURCE_ROOT/binutils-* \
      $SOURCE_ROOT/gcc-* \
      $SOURCE_ROOT/hwloc-* \
      $HOME/.m2 $HOME/.cache \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


#######################################################################
FROM ubuntu:18.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV PREFIX=/opt/scylladb
ENV LD_LIBRARY_PATH=$PREFIX/scylla/libreloc
ENV SCYLLA_HOME=$PREFIX/scylla
ENV SOURCE_ROOT=/tmp/source

WORKDIR $SOURCE_ROOT


COPY --from=builder $SOURCE_ROOT/scylla/build/release/dist/tar/scylla-package.tar.gz $SOURCE_ROOT/

RUN mkdir -p $PREFIX && cd $PREFIX \
    && tar xzf $SOURCE_ROOT/scylla-package.tar.gz \
    && rm -rf $SOURCE_ROOT

WORKDIR /root
EXPOSE  10000 9042 9160 9180 7000 7001

CMD ["/opt/scylladb/scylla/libexec/scylla", \
     "--options-file", "/opt/scylladb/scylla/conf/scylla.yaml", \
     "--max-io-requests", "65"]

# End of Dockerfile
