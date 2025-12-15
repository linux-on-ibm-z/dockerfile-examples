# © Copyright IBM Corporation 2019, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for ScyllaDB version 6.1.1 #########
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
FROM ubuntu:24.04 AS builder

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=$HOME/.local/bin:/root/.cargo/bin:/usr/local/bin:/bin:$PATH
ENV JAVA8_HOME=/usr/lib/jvm/java-8-openjdk-s390x
ENV EXTRA_CFLAGS="--gcc-install-dir=/usr/bin/../lib/gcc/s390x-linux-gnu/12 "

ENV PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/ScyllaDB/6.1.1/patch/"

ARG TARGET=native

WORKDIR $SOURCE_ROOT

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libaio-dev systemtap-sdt-dev lksctp-tools xfsprogs \
    libyaml-dev openssl libevent-dev libmpfr-dev libmpcdec-dev libssl-dev libsystemd-dev \
    libsctp-dev libsnappy-dev libpciaccess-dev libxml2-dev xfslibs-dev libgnutls28-dev \
    libiconv-hook-dev liblzma-dev libbz2-dev libxslt-dev libc-ares-dev libprotobuf-dev \
    protobuf-compiler libcrypto++-dev libtool perl ant libffi-dev rapidjson-dev automake \
    make git maven ninja-build unzip bzip2 wget curl xz-utils texinfo diffutils liblua5.3-dev \
    libnuma-dev libunistring-dev pigz ragel stow patch locales valgrind software-properties-common\
    libudev-dev libdeflate-dev zlib1g-dev doxygen librapidxml-dev sudo patchelf gawk ethtool hwloc\
    libjsoncpp-dev libzstd-dev libxxhash-dev libboost-all-dev gdb devscripts dh-make \
    liblz4-dev cmake libhwloc-dev libyaml-cpp-dev wabt antlr3 net-tools openjdk-11-jdk \
    gcc-12 g++-12 python3 python3-pip python3-aiohttp python3-magic \
    python3-colorama python3-tabulate python3-boto3 python3-pytest python3-pytest-asyncio \
    python3-redis python3-unidiff python3-humanfriendly python3-jinja2 python3-geomet python3-treelib \
  && pip3 install --user --break-system-packages scylla-driver traceback-with-variables scylla-api-client allure-pytest \
  && python3 --version \
#######################################################################
  && sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 12 \
  && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 \
  && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12 \
  && sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 12 \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh /dev/stdin -y \
  && cargo install cxxbridge-cmd --version 1.0.188 wasm-opt \
  && cargo install wasm-opt \
  && rustup target add wasm32-wasip1 \
#######################################################################
  && curl -sSL https://apt.llvm.org/llvm.sh | bash -s 17 \
  && sudo rm -f /usr/bin/clang \
  && sudo rm -f /usr/bin/clang++ \
  && sudo ln -s /usr/bin/clang-17 /usr/bin/clang \
  && sudo ln -s /usr/bin/clang++-17 /usr/bin/clang++ \
  && sudo ldconfig \
#######################################################################
  && ver=3.5.2 \
  && cd "$SOURCE_ROOT" \
  && URL=https://github.com/antlr/antlr3/archive/${ver}.tar.gz \
  && curl -sSL $URL | tar xzf - \
  && cd antlr3-${ver} \
  && curl -sSL ${PATCH_URL}/antlr3.diff | patch -p1 \
  && cp runtime/Cpp/include/antlr3* /usr/local/include/ \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && git clone https://github.com/fmtlib/fmt.git \
  && cd fmt \
  && git checkout 10.2.1 \
  && cmake -DFMT_TEST=OFF -DCMAKE_CXX_STANDARD=20 -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DFMT_DOC=OFF -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON -DFMT_PEDANTIC=ON -DFMT_WERROR=ON -DBUILD_SHARED_LIBS=ON . \
  && make \
  && make install \
  && sudo ldconfig \
#######################################################################
  && sudo locale-gen en_US.UTF-8 \
  && export LC_ALL=C \
  && unset LANGUAGE \
#######################################################################
  && cd "$SOURCE_ROOT" \
  && git clone --depth 1 -b scylla-6.1.1 https://github.com/scylladb/scylla.git \
  && cd scylla \
  && git submodule update --init --force --recursive \
  && curl -sSL ${PATCH_URL}/scylladb.diff | patch -p1  \
  && sed -i 's,$$(<,$$(sed 's/-/~/' <,g' configure.py \
  && ./configure.py --mode="release" --target=${TARGET} --debuginfo=0 \
       --cflags="${EXTRA_CFLAGS}-I/usr/local/include" --ldflags="-L/usr/local/lib" \
  && ninja build -j`nproc` \
#######################################################################
# Packaging
  && cd "$SOURCE_ROOT"/scylla \
  && curl -sSL ${PATCH_URL}/python3.diff | patch -d tools/python3 -p1 \
  && mkdir -p /opt/scylladb/dependencies/ \
  && (cd /opt/scylladb/dependencies/ && curl -L -O https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-s390x.tar.gz) \
  && apt-get install -y python3-venv zip \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' SCYLLA-VERSION-GEN \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' tools/jmx/SCYLLA-VERSION-GEN \
  && sed -i 's,#!/bin/sh,#!/bin/bash,g' tools/java/SCYLLA-VERSION-GEN \
  && sed -i 's,"\\s\*\\\"",r"\\s*\\"",g' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '64d' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '64i\            if not line.startswith("processor"):' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '67,70d' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '67i\            cur_proc = int(key[10:])' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '68i\            results[cur_proc] = {}' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '69i\            for x in value.split(","):' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '70i\                key2, value2 = [y.strip() for y in x.split("=")]' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i '71i\                results[cur_proc][key2] = value2' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i 's,core id,identification,g' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla_io_setup" \
  && sed -i 's,re\.search(\"\.\*http,re\.search(r\"\.\*http,g' "$SOURCE_ROOT/scylla/dist/common/scripts/scylla-housekeeping" \
  && mkdir -p /lib64 \
  && ln -s /lib/s390x-linux-gnu/libthread_db.so /lib64/libthread_db.so \
  && mkdir -p /etc/crypto-policies/back-ends \
  && touch /etc/crypto-policies/back-ends/gnutls.config \
  && cd "$SOURCE_ROOT"/scylla \
  && ninja dist-deb \
#######################################################################
  && rm -rf $SOURCE_ROOT/antlr3-3.5.2 \
      $SOURCE_ROOT/fmt \
      $HOME/.m2 $HOME/.cache \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


#######################################################################
FROM ubuntu:24.04

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

COPY --from=builder $SOURCE_ROOT/scylla/build/dist/release/debian/*.deb $SOURCE_ROOT/
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
  && apt-get -y upgrade \
  && apt-get -y --no-install-suggests install dialog apt-utils \
  && bash -ec "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections" \
  && bash -ec "rm -rf /etc/rsyslog.conf" \
  && apt-get -y --no-install-suggests install hostname supervisor python3 python3-pip python3-yaml python3-distro curl rsyslog sudo systemd \
  && bash -ec "echo LANG=C.UTF-8 > /etc/default/locale" \
  && bash -ec "dpkg -i $SOURCE_ROOT/*.deb" \
  && apt-get -y clean all \
  && bash -ec "cat /scylla_bashrc >> /etc/bash.bashrc" \
  && mkdir -p /etc/supervisor.conf.d \
  && mkdir -p /var/log/scylla \
  && chown -R scylla:scylla /var/lib/scylla \
  && sed -i -e 's/^SCYLLA_ARGS=".*"$/SCYLLA_ARGS="--log-to-syslog 0 --log-to-stdout 1 --network-stack posix"/' /etc/default/scylla-server \
  && mkdir -p /opt/scylladb/supervisor \
  && touch /opt/scylladb/SCYLLA-CONTAINER-FILE \
  && python3 -m pip install --break-system-packages scylla-driver traceback-with-variables \
  && rm -rf $SOURCE_ROOT

COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla-server.sh /opt/scylladb/supervisor/scylla-server.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla-node-exporter.sh /opt/scylladb/supervisor/scylla-node-exporter.sh
COPY --from=builder $SOURCE_ROOT/scylla/dist/common/supervisor/scylla_util.sh /opt/scylladb/supervisor/scylla_util.sh

ENV PATH=/opt/scylladb/python3/bin:/usr/bin:/usr/sbin
ENV LANG=C.UTF-8
ENV LANGUAGE=
ENV LC_ALL=C.UTF-8

WORKDIR /root
EXPOSE  10000 9042 9160 9180 7000 7001 22
VOLUME /var/lib/scylla

ENTRYPOINT ["/docker-entrypoint.py"]

# End of Dockerfile
