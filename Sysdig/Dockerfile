# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for Sysdig version 0.26.1 #########
#
# This Dockerfile builds a basic installation of Sysdig.
#
# Sysdig is open source, system-level exploration: capture system state and activity from a running Linux instance, then save, filter and analyze.
# Sysdig is scriptable in Lua and includes a command line interface and a powerful interactive UI, csysdig, that runs in your terminal.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To run sysdig in a Docker container use below command
#  docker run -it --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v
#   /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name <container_name> <image_name>
#
# The official website
# https://www.sysdig.org/
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

ARG SYSDIG_VER=0.26.1

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

LABEL RUN="docker run -i -t --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"

ENV SOURCEDIR=/tmp/source

WORKDIR $SOURCEDIR

# Install dependencies
RUN apt-get update \
	&& apt-get install -y \
		cmake \
		gcc \
		g++ \
		libelf-dev \
		linux-headers-$(uname -r) \
		lua5.1 \
		lua5.1-dev \
		patch \
		tar \
		wget \
# Download source code
	&& cd $SOURCEDIR \
	&& wget https://github.com/draios/sysdig/archive/${SYSDIG_VER}.tar.gz \
	&& tar -xvzf ${SYSDIG_VER}.tar.gz \
	&& cd sysdig-${SYSDIG_VER} \
	&& mkdir build \
# Patch sysdig
# Patch protobuf
	&& echo "--- src/google/protobuf/stubs/atomicops_internals_generic_gcc.h     2019-06-06 18:20:59.506309314 +0000" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+++ src/google/protobuf/stubs/atomicops_internals_generic_gcc.h     2019-06-05 19:19:01.626309314 +0000" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "@@ -146,6 +146,14 @@" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "   return __atomic_load_n(ptr, __ATOMIC_RELAXED);" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo " }" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+inline Atomic64 Release_CompareAndSwap(volatile Atomic64* ptr," >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+                                       Atomic64 old_value," >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+                                       Atomic64 new_value) {" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+  __atomic_compare_exchange_n(ptr, &old_value, new_value, false," >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+                              __ATOMIC_RELEASE, __ATOMIC_ACQUIRE);" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+  return old_value;" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+}" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo "+" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo " #endif // defined(__LP64__)" >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo >> $SOURCEDIR/protobuf-3.5.0.patch \
	&& echo " }  // namespace internal" >> $SOURCEDIR/protobuf-3.5.0.patch \
# Patch CMakeLists.txt
	&& sed -i "468iPATCH_COMMAND cp $SOURCEDIR/protobuf-3.5.0.patch . && patch -p0 -i protobuf-3.5.0.patch" CMakeLists.txt \
	&& sed -i "510s/1.1.4/1.8.1/" CMakeLists.txt \
# Patch userspace/libscap/scap_fds.c
	&& sed -i "28i#include <sys/sysmacros.h>" userspace/libscap/scap_fds.c \
# Configure Sysdig
	&& cd build \
	&& cmake -DUSE_BUNDLED_LUAJIT=OFF .. \
# Build and Install Sysdig
	&& make \
	&& make install \
# Copy important content from build
	&& mkdir -p /opt/sysdig \
	&& cp $SOURCEDIR/sysdig-${SYSDIG_VER}/build/driver/sysdig-probe.ko /opt/sysdig \
	&& cp -r $SOURCEDIR/sysdig-${SYSDIG_VER}/build/userspace/sysdig /opt/sysdig \
# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		cmake \
		gcc \
		g++ \
		linux-headers-$(uname -r) \
		lua5.1 \
		lua5.1-dev \
		patch \
		wget \
	&&	apt-get autoremove -y\
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCEDIR \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*

WORKDIR /opt/sysdig

CMD ["bash"]

# End of Dockerfile
