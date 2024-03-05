#!/bin/bash
# © Copyright IBM Corporation 2023
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#

set -o errexit -o nounset -o pipefail

WORK_ROOT=$(pwd)
SOURCE_ROOT=$(pwd)/build
PACKAGE_VERSION="7.0.2"
NETTY_TCNATIVE_VERSION="2.0.61"
NETTY_VERSION="4.1.93"
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/${PACKAGE_VERSION}/patch"

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
export PATH=$JAVA_HOME/bin:$PATH

function buildNetty() {
    # Install netty-tcnative 2.0.61
    cd $SOURCE_ROOT
    wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/netty-tcnative/2.0.61/build_netty.sh
    sed -i 's/"ubuntu-23.04"/"ubuntu-23.10"/g' build_netty.sh
    bash build_netty.sh -y

    # Install netty 4.1.93 Final
    cd $SOURCE_ROOT
    git clone https://github.com/netty/netty.git
    cd netty
    git checkout netty-$NETTY_VERSION.Final
    mvn clean install -DskipTests
}

apt-get install -y --no-install-recommends \
        bind9-host build-essential coreutils curl dnsutils ed expect file git gnupg2 iproute2 iputils-ping mkisofs \
        lcov less libssl-dev lsb-release netcat-openbsd openjdk-11-jdk-headless zip zlib1g-dev unzip wget python2 \
        python2-dev python-is-python3 python3 python3-dev python3-pip python3-requests python3-setuptools \
        python3-six python3-wheel python3-yaml wget sudo

mkdir -p $SOURCE_ROOT/

# Download and patch rules_java v5.5.1
cd $SOURCE_ROOT
git clone -b 7.1.0 https://github.com/bazelbuild/rules_java.git
cd rules_java
curl -sSL $PATCH_URL/rules_java_7.1.0.patch | git apply

# Download Bazel distribution archive
cd $SOURCE_ROOT
wget https://github.com/bazelbuild/bazel/releases/download/$PACKAGE_VERSION/bazel-$PACKAGE_VERSION-dist.zip
mkdir -p dist/bazel && cd dist/bazel
unzip -q ../../bazel-$PACKAGE_VERSION-dist.zip
chmod -R +w .
env EXTRA_BAZEL_ARGS="--tool_java_runtime_version=local_jdk" bash ./compile.sh

cd $SOURCE_ROOT
git clone --depth 1 -b $PACKAGE_VERSION https://github.com/bazelbuild/bazel.git
cd bazel
curl -sSLO $PATCH_URL/bazel.patch
sed -i "s#RULES_JAVA_ROOT_PATH#${SOURCE_ROOT}#g" bazel.patch
patch -p1 < bazel.patch

cd $SOURCE_ROOT
buildNetty

# Copy netty and netty-tcnative jar to respective bazel directory and apply a patch to use them
cp $SOURCE_ROOT/netty-tcnative/openssl-classes/target/netty-tcnative-classes-$NETTY_TCNATIVE_VERSION.Final.jar \
       $SOURCE_ROOT/netty-tcnative/boringssl-static/target/netty-tcnative-boringssl-static-$NETTY_TCNATIVE_VERSION.Final-linux-s390_64.jar \
       $SOURCE_ROOT/netty/buffer/target/netty-buffer-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/codec/target/netty-codec-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/codec-http/target/netty-codec-http-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/codec-http2/target/netty-codec-http2-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/common/target/netty-common-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/handler/target/netty-handler-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/handler-proxy/target/netty-handler-proxy-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/resolver/target/netty-resolver-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/resolver-dns/target/netty-resolver-dns-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/transport/target/netty-transport-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/transport-classes-epoll/target/netty-transport-classes-epoll-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/transport-classes-kqueue/target/netty-transport-classes-kqueue-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/transport-native-unix-common/target/netty-transport-native-unix-common-$NETTY_VERSION.Final-linux-s390_64.jar \
       $SOURCE_ROOT/netty/transport-native-kqueue/target/netty-transport-native-kqueue-$NETTY_VERSION.Final.jar \
       $SOURCE_ROOT/netty/transport-native-epoll/target/netty-transport-native-epoll-$NETTY_VERSION.Final-linux-s390_64.jar \
       $SOURCE_ROOT/bazel/third_party

cd $SOURCE_ROOT/bazel
${SOURCE_ROOT}/dist/bazel/output/bazel build -c opt --stamp --embed_label "$PACKAGE_VERSION" //src:bazel //src:bazel_jdk_minimal //src:test_repos //src/main/java/...

cd $WORK_ROOT
cp $SOURCE_ROOT/bazel/bazel-bin/src/bazel ./
chmod +x bazel
