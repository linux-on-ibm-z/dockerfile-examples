#!/bin/bash

set -o errexit -o nounset -o pipefail

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
export PATH=$JAVA_HOME/bin:$PATH
WORK_ROOT=$(pwd)
SOURCE_ROOT=$(pwd)/build
PACKAGE_VERSION="6.0.0"
NETTY_TCNATIVE_VERSION="2.0.51"
NETTY_TCNATIVE_PREVIOUS_VERSION="2.0.50"
NETTY_VERSION="4.1.75"
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/${PACKAGE_VERSION}/patch"

function buildNetty() {
	# Install netty-tcnative 2.0.51
	cd $SOURCE_ROOT
	git clone https://github.com/netty/netty-tcnative.git
	cp -r netty-tcnative netty-tcnative_$NETTY_TCNATIVE_PREVIOUS_VERSION
	mv netty-tcnative netty-tcnative_$NETTY_TCNATIVE_VERSION
	cd netty-tcnative_$NETTY_TCNATIVE_VERSION
	git checkout netty-tcnative-parent-$NETTY_TCNATIVE_VERSION.Final
	curl -sSL $PATCH_URL/netty-tcnative_$NETTY_TCNATIVE_VERSION.patch | patch -p1
	mvn install

	# Install netty-tcnative 2.0.50
	cd $SOURCE_ROOT
	cd netty-tcnative_$NETTY_TCNATIVE_PREVIOUS_VERSION
	git checkout netty-tcnative-parent-$NETTY_TCNATIVE_PREVIOUS_VERSION.Final
	curl -sSL $PATCH_URL/netty-tcnative_$NETTY_TCNATIVE_PREVIOUS_VERSION.patch | patch -p1
	mvn install

	# Install netty 4.1.75 Final
	cd $SOURCE_ROOT
	git clone https://github.com/netty/netty.git
	cd netty
	git checkout netty-$NETTY_VERSION.Final
	./mvnw clean install -DskipTests
}

apt-get install --yes --no-install-recommends \
    bind9-host build-essential coreutils curl dnsutils ed expect file git gnupg2 iproute2 iputils-ping \
    lcov less libssl-dev lsb-release netcat-openbsd openjdk-11-jdk-headless \
    python3 python3-dev python3-pip python3-requests python3-setuptools python3-six python3-wheel python3-yaml \
    unzip wget zip zlib1g-dev mkisofs \
    python2 python2-dev python-is-python3
apt-get install -y ninja-build cmake perl golang libssl-dev libapr1-dev autoconf automake libtool make tar git wget maven

mkdir -p $SOURCE_ROOT/
# Download Bazel distribution archive
cd $SOURCE_ROOT
wget https://github.com/bazelbuild/bazel/releases/download/$PACKAGE_VERSION/bazel-$PACKAGE_VERSION-dist.zip
mkdir -p dist/bazel && cd dist/bazel
unzip ../../bazel-$PACKAGE_VERSION-dist.zip
chmod -R +w .
curl -sSL $PATCH_URL/dist-md5.patch | git apply
env EXTRA_BAZEL_ARGS="--tool_java_runtime_version=local_jdk" bash ./compile.sh

cd $SOURCE_ROOT
git clone https://github.com/bazelbuild/bazel.git
cd bazel
git checkout "$PACKAGE_VERSION"
curl -sSL $PATCH_URL/bazel.patch | patch -p1

cd $SOURCE_ROOT
buildNetty

# Copy netty and netty-tcnative jar to respective bazel directory and apply a patch to use them
cp $SOURCE_ROOT/netty-tcnative_$NETTY_TCNATIVE_VERSION/boringssl-static/target/netty-tcnative-boringssl-static-$NETTY_TCNATIVE_VERSION.Final-linux-s390_64.jar \
	$SOURCE_ROOT/bazel/third_party/netty_tcnative/
cp $SOURCE_ROOT/netty/buffer/target/netty-buffer-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/codec/target/netty-codec-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/codec-http/target/netty-codec-http-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/codec-http2/target/netty-codec-http2-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/common/target/netty-common-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/handler/target/netty-handler-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/handler-proxy/target/netty-handler-proxy-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/resolver/target/netty-resolver-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/resolver-dns/target/netty-resolver-dns-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport/target/netty-transport-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport-sctp/target/netty-transport-sctp-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport-native-unix-common/target/netty-transport-native-unix-common-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport-native-unix-common/target/netty-transport-native-unix-common-$NETTY_VERSION.Final-linux-s390_64.jar \
    $SOURCE_ROOT/netty/transport-native-kqueue/target/netty-transport-native-kqueue-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport-native-epoll/target/netty-transport-native-epoll-$NETTY_VERSION.Final.jar \
    $SOURCE_ROOT/netty/transport-native-epoll/target/netty-transport-native-epoll-$NETTY_VERSION.Final-linux-s390_64.jar \
    $SOURCE_ROOT/bazel/third_party/netty/
cd $SOURCE_ROOT/bazel
curl -sSL $PATCH_URL/bazel-netty.patch | patch -p1
${SOURCE_ROOT}/dist/bazel/output/bazel build -c opt --stamp --embed_label "6.0.0" //src:bazel
mkdir -p output
cp bazel-bin/src/bazel output/bazel
# Rebuild bazel using itself
./output/bazel build -c opt --stamp --embed_label "6.0.0" //src:bazel

cd $WORK_ROOT
cp $SOURCE_ROOT/bazel/bazel-bin/src/bazel ./
chmod +x bazel
