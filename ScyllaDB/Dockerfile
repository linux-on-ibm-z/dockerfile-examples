# © Copyright IBM Corporation 2019, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for ScyllaDB version 5.4.6 #########
#
# This Dockerfile builds a basic installation of ScyllaDB.
#
# ScyllaDB is a high performance distributed NoSQL database.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build --build-arg TARGET=<target_value> -t <image_name> .
#
# To start up a Scylla node and access utilities, see
# https://docs.scylladb.com/stable/operating-scylla/procedures/tips/best-practices-scylla-on-docker.
#
#######################################################################

# Base Image
FROM ubuntu:22.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=/root/.cargo/bin:/usr/local/bin:/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/usr/local/lib64:/usr/local/lib:/usr/lib64:$LD_RUN_PATH
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV CC=clang-17
ENV CXX=clang++
ENV ver=1.0
ENV URL=https
ENV LC_ALL=C
ENV JAVA8_HOME=/usr/lib/jvm/java-8-openjdk-s390x

ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ScyllaDB/5.4.6/patch/"

ARG TARGET=native

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gcc g++ \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libaio-dev systemtap-sdt-dev lksctp-tools xfsprogs \
    libyaml-dev openssl libevent-dev libmpfr-dev libmpcdec-dev libssl-dev libsystemd-dev \
    libsctp-dev libsnappy-dev libpciaccess-dev libxml2-dev xfslibs-dev libgnutls28-dev \
    libiconv-hook-dev liblzma-dev libbz2-dev libxslt-dev libc-ares-dev libprotobuf-dev \
    protobuf-compiler libcrypto++-dev libtool perl ant libffi-dev rapidjson-dev automake \
    make git maven ninja-build unzip bzip2 wget curl xz-utils texinfo diffutils liblua5.3-dev \
    libnuma-dev libunistring-dev python3 python3-pip pigz ragel stow patch locales valgrind \
    libudev-dev libdeflate-dev zlib1g-dev libabsl-dev \
    net-tools ethtool gnutls-bin patchelf util-linux doxygen sudo clang-12 librapidxml-dev \
    gawk gzip openjdk-11-jdk devscripts dh-make \
  && python3 -m pip install --user --upgrade pip \
  && python3 -m pip install --user pyparsing colorama pyyaml boto3 requests pytest scylla-driver \
      traceback-with-variables scylla-api-client aiohttp tabulate pytest-asyncio python-magic \
  && python3 --version \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh /dev/stdin -y \
  && cargo install cxxbridge-cmd --root $SOURCE_ROOT/cxxbridge \
  && cp -r $SOURCE_ROOT/cxxbridge/. /usr/local \
  && rustup target add wasm32-wasi \
#######################################################################
  && ver=2.38 \
  && cd "$SOURCE_ROOT" \
  && URL="http://ftpmirror.gnu.org/binutils/binutils-${ver}.tar.gz" \
  && curl -sSL $URL | tar xzf - \
  && cd binutils-${ver} \
  && mkdir objdir \
  && cd objdir \
  && CC=/usr/bin/gcc ../configure --prefix=/usr --build=s390x-linux-gnu \
  && make -j 8 \
  && make install \
  && rm /usr/bin/s390x-linux-gnu-ld /usr/bin/s390x-linux-gnu-ld.bfd \
  && ln -s /usr/bin/ld /usr/bin/s390x-linux-gnu-ld \
  && ln -s /usr/bin/ld.bfd /usr/bin/s390x-linux-gnu-ld.bfd \
#######################################################################
  && curl -sSL https://apt.llvm.org/llvm.sh | bash -s 17 \
  && sudo rm -f /usr/bin/clang \
  && sudo rm -f /usr/bin/clang++ \
  && sudo ln -s /usr/bin/clang-17 /usr/bin/clang \
  && sudo ln -s /usr/bin/clang++-17 /usr/bin/clang++ \
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
  && ver=2.4.1 \
  && cd "$SOURCE_ROOT" \
  && URL=https://download.open-mpi.org/release/hwloc/v2.4/hwloc-${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd hwloc-${ver} \
  && ./configure \
  && make install \
#######################################################################
  && ver=1.9.5 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/open-source-parsers/jsoncpp/archive/${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - || error "jsoncpp $ver" \
  && cd jsoncpp-${ver} \
  && mkdir -p build/release \
  && cd build/release \
  && /usr/local/bin/cmake ../.. \
  && make -j 8 \
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
  && URL=https://sourceforge.net/projects/boost/files/boost/1.74.0/boost_1_74_0.tar.gz \
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
  && curl -sSL ${PATCH_URL}/thrift.diff | patch -p1  \
  && ./configure --without-java --without-lua --without-go --disable-tests --disable-tutorial \
  && make -j 2 \
  && make install \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && git clone https://github.com/fmtlib/fmt.git \
  && cd fmt \
  && git checkout 9.1.0 \
  && /usr/local/bin/cmake -DFMT_TEST=OFF -DCMAKE_CXX_STANDARD=17 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_VISIBILITY_PRESET=hidden -DCMAKE_POSITION_INDEPENDENT_CODE=ON . \
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
  && cd "$SOURCE_ROOT" \
  && export PATH="$HOME/.cargo/bin:$PATH" \
  && echo "$PATH" \
  &&  cd "$SOURCE_ROOT" \
  && git clone --recursive --depth 1 https://github.com/WebAssembly/wabt \
  && cd wabt \
  && mkdir build \
  && cd build \
  && cmake .. \
  && cmake --build . \
  && sudo make install \
  && cargo install wasm-opt \
#######################################################################
  && sudo apt-get install -y gcc-12 gcc-12 \
  && sudo apt-get install -y gcc-12 g++-12 \
  && sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 100 \
  && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 \
  && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100 \
  && sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 100 \
  && sudo locale-gen en_US.UTF-8 \
  && export LC_ALL=C \
  && unset LANGUAGE \
  && cd "$SOURCE_ROOT" \
  && git clone --depth 1 -b scylla-5.4.6 https://github.com/scylladb/scylla.git \
  && cd scylla \
  && git submodule update --init --force --recursive \
  && curl -sSL ${PATCH_URL}/python3.diff | patch -d tools/python3 -p1 \
  && curl -sSL ${PATCH_URL}/scylla_ub.diff | patch -p1  \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' SCYLLA-VERSION-GEN \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' tools/jmx/SCYLLA-VERSION-GEN \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' tools/java/SCYLLA-VERSION-GEN \
  && sed -i 's/boost\/function_output_iterator\.hpp/boost\/iterator\/function_output_iterator\.hpp/g' \
    /usr/local/include/boost/signals2/detail/null_output_iterator.hpp \
  && ./configure.py --mode=release --target=${TARGET} --debuginfo=0 \
    --cflags="-I/usr/local/include -I/usr/local/include/boost" \
    --compiler="${CXX}" --c-compiler="${CC}"\
  && sed -i -E 's/(build \$builddir\/release\/service\/storage_proxy\.o.+)/\1\n   optimize = -O0/g' ./build.ninja \
  && sed -i -E 's/(build \$builddir\/release\/service\/raft\/group0_state_machine\.o.+)/\1\n   optimize = -O0/g' ./build.ninja \
  && ninja build -j`nproc` \
#######################################################################
# Packaging
  && cd "$SOURCE_ROOT"/scylla \
  && mkdir -p /opt/scylladb/dependencies/ \
  && (cd /opt/scylladb/dependencies/ && curl -L -O https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-s390x.tar.gz) \
  && ln -s /usr/local/bin/hwloc-* /usr/bin/ \
  && mkdir -p /lib64 \
  && ln -s /lib/s390x-linux-gnu/libthread_db.so /lib64/libthread_db.so \
  && mkdir -p /etc/crypto-policies/back-ends \
  && touch /etc/crypto-policies/back-ends/gnutls.config \
  && apt-get install -y python3-venv zip \
  && sed -i '1s|#!/bin/sh|#!/bin/bash|' SCYLLA-VERSION-GEN \
  && sed -i 's|VERSION=$(./SCYLLA-VERSION-GEN|VERSION=$(bash ./SCYLLA-VERSION-GEN|' "$SOURCE_ROOT/scylla/tools/cqlsh/reloc/build_reloc.sh" \
  && chmod +x ./SCYLLA-VERSION-GEN \
  && cd "$SOURCE_ROOT"/scylla \
  && ninja dist-deb \
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
      $SOURCE_ROOT/xxHash-* \
      $SOURCE_ROOT/valgrind-* \
      $HOME/.m2 $HOME/.cache \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


#######################################################################
FROM ubuntu:22.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

COPY --from=builder $SOURCE_ROOT/scylla/build/dist/release/debian/*.deb $SOURCE_ROOT/
COPY --from=builder $SOURCE_ROOT/scylla/tools/java/build/debian/*.deb $SOURCE_ROOT/
COPY --from=builder $SOURCE_ROOT/scylla/tools/jmx/build/debian/*.deb $SOURCE_ROOT/
COPY --from=builder $SOURCE_ROOT/scylla/tools/python3/build/debian/*.deb $SOURCE_ROOT/
COPY --from=builder $SOURCE_ROOT/scylla/tools/cqlsh/build/debian/*.deb $SOURCE_ROOT/
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/etc etc/
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/scylla-housekeeping-service.sh /scylla-housekeeping-service.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/scyllasetup.py /scyllasetup.py
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/commandlineparser.py /commandlineparser.py
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/docker-entrypoint.py /docker-entrypoint.py
COPY --from=builder $SOURCE_ROOT/scylla/dist/docker/scylla_bashrc /scylla_bashrc

RUN apt-get -y clean expire-cache \
  && apt-get -y update \
  && apt-get -y install dialog apt-utils \
  && bash -ec "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections" \
  && bash -ec "rm -rf /etc/rsyslog.conf" \
  && apt-get -y install hostname supervisor openssh-server openssh-client openjdk-11-jre-headless python2 python3 python3-yaml python3-pip curl rsyslog locales sudo \
  && locale-gen en_US.UTF-8 \
  && bash -ec "echo LANG=C.UTF-8 > /etc/default/locale" \
  && bash -ec "dpkg -i $SOURCE_ROOT/*.deb" \
  && apt-get -y clean all \
  && bash -ec "cat /scylla_bashrc >> /etc/bash.bashrc" \
  && mkdir -p /etc/supervisor.conf.d \
  && mkdir -p /var/log/scylla \
  && chown -R scylla:scylla /var/lib/scylla \
  && sed -i -e 's/^SCYLLA_ARGS=".*"$/SCYLLA_ARGS="--log-to-syslog 0 --log-to-stdout 1 --default-log-level info --network-stack posix"/' /etc/default/scylla-server \
  && mkdir -p /opt/scylladb/supervisor \
  && touch /opt/scylladb/SCYLLA-CONTAINER-FILE \
  && python3 -m pip install traceback-with-variables \
  && bash -ec "echo 'fs.aio-max-nr = 1048576' |& sudo tee -a /etc/sysctl.conf" \
  && bash -ec "sysctl -p" \
  && rm -rf $SOURCE_ROOT

COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla-server.sh /opt/scylladb/supervisor/scylla-server.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla-jmx.sh /opt/scylladb/supervisor/scylla-jmx.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla-node-exporter.sh /opt/scylladb/supervisor/scylla-node-exporter.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla_util.sh /opt/scylladb/supervisor/scylla_util.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/scripts/scylla_dev_mode_setup /opt/scylladb/scripts/scylla_dev_mode_setup

ENV PATH=/opt/scylladb/python3/bin:/usr/bin:/usr/sbin
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /root
EXPOSE  10000 9042 9160 9180 7000 7001 22
VOLUME /var/lib/scylla

ENTRYPOINT ["/docker-entrypoint.py"]

# End of Dockerfile
