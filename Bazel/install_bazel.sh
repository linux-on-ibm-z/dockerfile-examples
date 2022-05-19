#!/bin/bash

set -o errexit -o nounset -o pipefail

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
export PATH=$JAVA_HOME/bin:$PATH
WORK_ROOT=$(pwd)
SOURCE_ROOT=$(pwd)/build
PACKAGE_VERSION="5.1.1"
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/${PACKAGE_VERSION}/patch"

function buildNetty() {
	# Install netty-tcnative 2.0.44
	cd $SOURCE_ROOT
	git clone https://github.com/netty/netty-tcnative.git
	cd netty-tcnative
	git checkout netty-tcnative-parent-2.0.44.Final
	curl -sSL $PATCH_URL/netty-tcnative.patch | git apply
	mvn install

	# Install netty 4.1.69 Final
	cd $SOURCE_ROOT
	git clone https://github.com/netty/netty.git
	cd netty
	git checkout netty-4.1.69.Final
	curl -sSL $PATCH_URL/netty.patch | git apply
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
curl -sSL $PATCH_URL/bazel.patch | git apply

cd $SOURCE_ROOT
buildNetty

# Copy netty and netty-tcnative jar to respective bazel directory and apply a patch to use them
cp $SOURCE_ROOT/netty-tcnative/boringssl-static/target/netty-tcnative-boringssl-static-2.0.44.Final-linux-s390_64.jar \
   	$SOURCE_ROOT/bazel/third_party/netty_tcnative/netty-tcnative-boringssl-static-2.0.44.Final.jar
cp $SOURCE_ROOT/netty/buffer/target/netty-buffer-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/codec/target/netty-codec-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/codec-http/target/netty-codec-http-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/codec-http2/target/netty-codec-http2-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/common/target/netty-common-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/handler/target/netty-handler-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/handler-proxy/target/netty-handler-proxy-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/resolver/target/netty-resolver-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/resolver-dns/target/netty-resolver-dns-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport/target/netty-transport-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport-sctp/target/netty-transport-sctp-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport-native-unix-common/target/netty-transport-native-unix-common-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport-native-unix-common/target/netty-transport-native-unix-common-4.1.69.Final-linux-s390_64.jar \
   	$SOURCE_ROOT/netty/transport-native-kqueue/target/netty-transport-native-kqueue-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport-native-epoll/target/netty-transport-native-epoll-4.1.69.Final.jar \
   	$SOURCE_ROOT/netty/transport-native-epoll/target/netty-transport-native-epoll-4.1.69.Final-linux-s390_64.jar \
   	$SOURCE_ROOT/bazel/third_party/netty/
cd $SOURCE_ROOT/bazel
curl -sSL $PATCH_URL/bazel-netty.patch | git apply
${SOURCE_ROOT}/dist/bazel/output/bazel build -c opt --stamp --embed_label "5.1.1" //src:bazel
mkdir -p output
cp bazel-bin/src/bazel output/bazel
# Rebuild bazel using itself
./output/bazel build -c opt --stamp --embed_label "5.1.1" //src:bazel

cd $WORK_ROOT
cp $SOURCE_ROOT/bazel/bazel-bin/src/bazel ./
chmod +x bazel
