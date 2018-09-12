# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Swift version 4.1.2 ###################################################################
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


#  Build swift
ENV WORKDIR=/root
ENV MYDESTDIR=/usr/share/swift
ENV PATH=$MYDESTDIR/usr/bin:/opt/llvm/bin:/opt/binutils-2.27/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

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
	libcurl4-openssl-dev \
	systemtap-sdt-dev \	
	tzdata \
    bison \
	flex \
	texinfo	\
	wget \
 
#  Install blocksruntime
 && cd $WORKDIR && git clone https://github.com/mackyle/blocksruntime && cd blocksruntime && ./buildlib && env prefix=/usr ./installlib \  

#  Install gold linker
 && cd $WORKDIR \
 && git clone git://sourceware.org/git/binutils-gdb.git && cd binutils-gdb \
 && git checkout tags/binutils-2_27 \
 && ./configure --prefix=/opt/binutils-2.27 --enable-gold \
 && make && make install \
 
     
#  Build llvm/clang
 && cd $WORKDIR && mkdir llvm && cd llvm \
 && git clone https://git.llvm.org/git/llvm.git  \
 && cd llvm && git checkout release_40 \
 && cd tools \
 && git clone https://git.llvm.org/git/clang.git && cd clang \ 
 && git checkout release_40 && cd ../../projects \ 
 && git clone https://git.llvm.org/git/compiler-rt.git  \
 && cd compiler-rt && git checkout release_40 && cd ../../..  \
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

# Install libedit
 && cd $WORKDIR  \
 && wget http://thrysoee.dk/editline/libedit-20170329-3.1.tar.gz \
 && tar zxf libedit-20170329-3.1.tar.gz \
 && cd libedit-20170329-3.1 \
 && ./configure && make && make install &&  cd .. \
 && ln -s /usr/local/lib/libedit.so.0.0.56 /usr/local/lib/libedit.so.2 \
 
  
# Clone and Install Swift 
 && cd $WORKDIR && mkdir swift4 && cd swift4 \
 && git clone https://github.com/linux-on-ibm-z/swift.git \ 
 && cd swift \
 && git checkout swift-4.1.2-s390x \ 
 && ./utils/update-checkout --clone --scheme swift-4.1.2-s390x --config $PWD/utils/update-checkout-config-s390x.json \  
 && ./utils/build-script -j 2 -r \
    --lldb --foundation --xctest --llbuild --swiftpm --libdispatch -- \
    --verbose-build=1 \
    --install-swift --install-foundation --install-xctest --install-llbuild --install-swiftpm --install-libdispatch --install-lldb \
    --swift-install-components='autolink-driver;compiler;clang-builtin-headers;stdlib;sdk-overlay;license' \
    --build-swift-static-stdlib=1 \
    --install-prefix=/usr \
    --install-destdir=$MYDESTDIR \
 
 && cd $MYDESTDIR \
 
# Clean up unused packages and data
 && apt-get remove -y \
    autoconf \
	cmake \
	git


CMD ["swiftc" , "--version"]
