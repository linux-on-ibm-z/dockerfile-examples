# © Copyright IBM Corporation 2018, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Swift version 5.1 ###################################################################
#
# Swift is a general-purpose, multi-paradigm, compiled programming language.
# It makes writing and maintaining correct programs easier for the developer
# It was designed from the outset to be safer than C-based languages, and eliminates entire classes of unsafe code
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run --name <container_name> -it <image_name> /bin/bash
#
# Use below command to compile swift:
# docker run --rm=true -v /<path-to-swift-file-on-host>:/<path-to-swift-file-on-container> -d <image_name> swiftc -o /<path-to-swift-file-on-container>/<executable_name> /<path-to-swift-file-on-container>/<swift_file>
# For ex. docker run --rm=true -v /opt/data:/home/data -d <image_name> swiftc -o /home/data/output_file /home/data/sample_file.swift
#
# To run the executable:
# docker run --rm=true -v /<path-to-swift-file-on-host>:/<path-to-swift-file-on-container> -d <image_name> ./<path-to-swift-file-on-container>/<executable_name>
# For ex. docker run --rm=true -v /opt/data:/home/data -d <image_name> ./home/data/output_file
#
# Note: 1) The above command creates the swift executable in mounted volume.
#       2) Mounted folder within container must not be /root/ to avoid overwriting of data
#
##################################################################################################################

FROM s390x/ubuntu:18.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

#  Build swift
ENV SWIFT_SOURCE_DIR=/root
ENV SWIFT_BUILD_DIR=$SWIFT_SOURCE_DIR/build/buildbot_linux
ENV SWIFT_INSTALL_DIR=$SWIFT_SOURCE_DIR/swift-install
ENV SWIFT_INSTALL_PKG=$SWIFT_INSTALL_DIR/install.tar.gz
ENV PATH=$SWIFT_INSTALL_DIR/usr/bin:/opt/llvm/bin:/opt/binutils-2.27/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV GIT_USER_EMAIL="lzhang@ca.ibm.com"
ENV GIT_USER_NAME="Lei Zhang"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
        autoconf \
        libtool \
        git \
        cmake \
        ninja-build \
        python \
        python-dev \
        python3-dev \
        uuid-dev \
        libicu-dev \
        icu-devtools \
        libbsd-dev \
        libedit-dev \
        libxml2-dev \
        libsqlite3-dev \
        swig \
        libpython-dev \
        libncurses5-dev \
        pkg-config \
        rsync \
        libcurl4-openssl-dev \
        systemtap-sdt-dev \
        tzdata \
        clang \
        wget

# Clone and Install Swift
RUN cd $SWIFT_SOURCE_DIR \
 && git clone -b swift-5.1-branch https://github.com/apple/swift.git \
 && cd swift \
 && ./utils/update-checkout --clone --scheme swift-5.1-branch \

# Apply patches for swift
 && git fetch \
 && git config --global user.email $GIT_USER_EMAIL \
 && git config --global user.name $GIT_USER_NAME \
 && git cherry-pick cacf9c72b6f5ca7249dcf4b1cb81de6d8b120acb \
 && git cherry-pick 04976e1a75d37592d6d6d688de07a210d0c046ef \
 && git cherry-pick 6bb79cafd9e4de34ffc4b2c798960466cf3da70f \
 && git cherry-pick 25a075cbb6abba3d71d833abe704bc13f12350a2 \
 && git cherry-pick d3262ec10d7e41b9403f83f2f89474795f9eed3a \
 && git cherry-pick 253d5b5d18c9be2eae2b94be60976ab91f3e4ef6 \
 && git cherry-pick a06abbb3b5f3b6cae3ec5dfefe883dbfb6993118 \
 && git cherry-pick 931eccb34d34548c8d3e86bf08b471185988fe8b \
 && git cherry-pick e08359c2013a154e1bc740e1984a1c3b645cd7fe \
 && git cherry-pick ce3aff12da2821314b6555c6ff98de4abeaa5cdc \
 && git cherry-pick 2f8b5ac9e2f4395f2633b0dfe03b7d6fd1685b7d \
 && git cherry-pick 6ab83122acf6cc8f98e24a3d47e62483d63c4df9 \
 && git cherry-pick 71fa7ece3fcfe4900f5a75b775efe2a7e94663db \
 && git cherry-pick 43bfbd5f38bbc72a4d79f103c962f4a9e9adefff \
 && git cherry-pick 8b3c1a459b13a27f63e7a967f6071d146606d4bc \
 && git cherry-pick bb2740e540a4679c26d80d9e58d29ef50a38349f \
 && git cherry-pick 192bcb2007b89bc941d7ea6f348301f3ecf5ee86 \
 && git cherry-pick eb1c203cbf0a306cf084579f090b1ea6ebd55125 \
 && git cherry-pick 6ac15e93482ccd988b2bbc7d3d50a72899c62ed7 \
 && git cherry-pick 81ece42b1847d6cb647fd8f21910d0f0aa71df42 \
 && git remote add loz https://github.com/linux-on-ibm-z/swift.git \
 && git fetch loz \
 && git cherry-pick cbf68876f51fa804fd538b4f2ad0b2f70c893a57 \

# Apply patches for Swift Foundation
 && cd ../swift-corelibs-foundation/ \
 && git remote add loz https://github.com/linux-on-ibm-z/swift-corelibs-foundation.git \
 && git fetch loz \
 && git cherry-pick 68412be28a843e37e0be2557669d13024443d718 \

# Apply patches for LLDB
 && cd ../lldb \
 && git cherry-pick 852d35a9c161fd44222b14ebe10fb06529c96817 \

# Apply patches for Swift Package Manager
 && cd ../swiftpm \
 && git cherry-pick b8768525da66690622b37ce8ebc034945604154e \

 && cd $SWIFT_SOURCE_DIR \
 && env LD_LIBRARY_PATH=$SWIFT_BUILD_DIR/swift-linux-s390x/lib/swift/linux/s390x/:$SWIFT_BUILD_DIR/swift-linux-s390x/libdispatch-prefix/lib/ $SWIFT_SOURCE_DIR/swift/utils/build-script --preset=buildbot_linux,no_test install_destdir=$SWIFT_INSTALL_DIR installable_package=$SWIFT_INSTALL_PKG

CMD ["swiftc" , "--version"]
