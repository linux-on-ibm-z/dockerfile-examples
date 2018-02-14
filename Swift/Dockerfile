########## Dockerfile for Swift version 4.0.2 ###################################################################
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

FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"

#  Build swift
ENV MYDESTDIR=/usr/share/swift
ENV PATH=$MYDESTDIR/usr/bin:/opt/llvm/bin:/opt/binutils-2.27/bin:$PATH

RUN apt-get update && apt-get -y install \
	autoconf \
	bison \
	cmake \
	flex \
	git \
	icu-devtools \
	libbsd-dev \
	libcurl4-openssl-dev \
	libedit-dev \
	libicu-dev \
	libncurses5-dev \
	libpython-dev \
	libsqlite3-dev \
	libtool \
	libxml2-dev \
	ninja-build \
	pkg-config \
	python \
	python3-dev \
	python-dev \
	sudo \
	swig \
	texinfo \
	tzdata \
	uuid-dev \
 && apt-get clean \

#  Install blocksruntime
 && git clone https://github.com/mackyle/blocksruntime && cd blocksruntime && ./buildlib && sudo env prefix=/usr ./installlib \ 
 && rm -rf /root/blocksruntime \

#  Install gold linker
 && cd /root && git clone git://sourceware.org/git/binutils-gdb.git && cd binutils-gdb \
 && git checkout tags/binutils-2_27 \
 && ./configure --prefix=/opt/binutils-2.27 --enable-gold \
 && make && sudo make install \
 && rm -rf /root/binutils-gdb \
     
#  Build llvm/clang
 && cd /root && mkdir llvm && cd llvm \
 && git clone https://github.com/linux-on-ibm-z/llvm.git  \
 && cd llvm && git checkout llvm-for-swift-3.1 && cd tools \
 && git clone https://github.com/linux-on-ibm-z/clang.git && cd clang \ 
 && git checkout clang-for-swift-3.1 && cd ../../projects \ 
 && git clone https://github.com/linux-on-ibm-z/compiler-rt.git  \
 && cd compiler-rt && git checkout compiler-rt-for-swift-3.0 && cd ../../.. \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/llvm \
          -DPYTHON_INCLUDE_DIR=/usr/include/python2.7 \
          -DPYTHON_LIBRARY=/usr/lib/python2.7/config-s390x-linux-gnu/libpython2.7.so \
          -DCURSES_INCLUDE_PATH=/usr/include \
          -DCURSES_LIBRARY=/usr/lib/s390x-linux-gnu/libncurses.so \
          -DCURSES_PANEL_LIBRARY=/usr/lib/s390x-linux-gnu/libpanel.so \
          ../llvm \ 
 && make -j4 \ 
 && make install \ 
 && rm -rf /root/llvm /root/build \
 
# Clone and Install Swift 
 && cd /root && mkdir swift31 && cd swift31 \
 && git clone https://github.com/linux-on-ibm-z/swift.git \ 
 && cd swift \
 && git checkout swift-4.0.2-RELEASE-s390x \ 
 && ./utils/update-checkout --clone --scheme swift-4.0.2-RELEASE-s390x --config $PWD/utils/update-checkout-config-s390x.json \ 
 && rm -f ./utils/swift_build_support/__init__.pyc \ 
 && cd ../swift-corelibs-libdispatch \ 
 && git submodule init \ 
 && git submodule update --recursive \ 
 && cd ../swift \ 
 && mkdir $MYDESTDIR \ 
 && ./utils/build-script -j 2 -r \
        --foundation --xctest --llbuild --swiftpm --libdispatch -- \
        --verbose-build=1 \
        --install-swift --install-foundation --install-xctest --install-llbuild --install-swiftpm --install-libdispatch \
        --swift-install-components='autolink-driver;compiler;clang-builtin-headers;stdlib;sdk-overlay;license' \
        --build-swift-static-stdlib=1 \
        --install-prefix=/usr \
        --install-destdir=$MYDESTDIR \ 
 && rm -rf /swift31 /tmp/* /var/tmp/* /root/swift31 \
 
# Clean up unused packages and data
 && apt-get remove -y \
    autoconf \
	cmake \
	git  \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

CMD ["swiftc" , "--version"]
