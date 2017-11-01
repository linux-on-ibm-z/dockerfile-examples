########## Dockerfile for TensorFlow version 1.2.1 #########
#
# This Dockerfile builds a basic installation of TensorFlow.
#
# TensorFlow provides multiple APIs. The lowest level API--TensorFlow Core-- provides you with complete programming control.
# The higher level APIs are built on top of TensorFlow Core. These higher level APIs are typically easier to learn and use than TensorFlow Core.
# In addition, the higher level APIs make repetitive tasks easier and more consistent between different users. 
# A high-level API like tf.estimator helps you manage data sets, estimators, training and inference.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start container from image & start an application in production mode
# docker run --name <container_name> -d <image>
# 
# To copy TensorFlow wheel file :
# docker cp <container_id>:/tensorflow_wheel <path_on_host>
#
# You can install TensorFlow wheel file using pip install
#
# Reference:
# https://www.tensorflow.org/
# http://bazel.io/
# https://github.com/tensorflow/tensorflow
# 
##################################################################################

# Base Image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER  LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source PATH=$PATH:$SOURCE_DIR/bazel/output/ TF_NEED_GCP=0 \
	TF_NEED_HDFS=0 TF_NEED_CUDA=0 PYTHON_BIN_PATH=/usr/bin/python2

# Install dependencies
RUN	apt-get update && apt-get install -y \
		autoconf \
		automake \
		bzip2 \
		curl \
		g++ \
		git \
		glibc* \
		libcurl3-dev \
		libtool \
		make \
		maven \
		openjdk-8-jdk \
		pkg-config \
		python-dev \
		python-numpy \
		python-mock \
		python-pip \
		python-scipy \
		python-sklearn \
		python-virtualenv \
		swig \
		tar \
		unzip \
		vim \
		wget \
		zip \
		zlib1g-dev \
	&&	easy_install pip \
	&&	pip install \
		backports.weakref \
		portpicker \
		wheel \
		
# Build Bazel
	&&	mkdir -p $SOURCE_DIR \
	&&	cd $SOURCE_DIR \
	&&	mkdir bazel \
	&&	cd bazel \
	&&	wget https://github.com/bazelbuild/bazel/releases/download/0.4.5/bazel-0.4.5-dist.zip \
	&&	unzip bazel-0.4.5-dist.zip  \
	&&	chmod -R +w . \
	
# Modify file
	&&	file=third_party/protobuf/3.0.0/src/google/protobuf/stubs/atomicops_internals_generic_gcc.h \
	&&	sed -i '131i inline Atomic64 NoBarrier_AtomicIncrement(volatile Atomic64* ptr,' $file \
	&&	sed -i '132i Atomic64 increment) {' $file \
	&&	sed -i '133i return __atomic_add_fetch(ptr, increment, __ATOMIC_RELAXED);' $file \
	&&	sed -i '134i }' $file \
	&&	sed -i '135i inline void NoBarrier_Store(volatile Atomic64* ptr, Atomic64 value) {' $file \
	&&	sed -i '136i __atomic_store_n(ptr, value, __ATOMIC_RELAXED);' $file \
	&&	sed -i '137i }' $file \
	&&	sed -i '138i inline Atomic64 NoBarrier_AtomicExchange(volatile Atomic64* ptr,' $file \
	&&	sed -i '139i Atomic64 new_value) {' $file \
	&&	sed -i '140i return __atomic_exchange_n(ptr, new_value, __ATOMIC_RELAXED);' $file \
	&&	sed -i '141i }' $file \
	&&	sed -i '142i inline Atomic64 NoBarrier_Load(volatile const Atomic64* ptr) {' $file \
	&&	sed -i '143i return __atomic_load_n(ptr, __ATOMIC_RELAXED);' $file \
	&&	sed -i '144i }' $file \
	&&	sed -i '116d' scripts/bootstrap/compile.sh \
	&&	sed -i '116 i run "${JAVAC}" -J-Xms1g -J-Xmx1g -classpath "${classpath}" -sourcepath "${sourcepath}" \\' scripts/bootstrap/compile.sh \
	&&	bash ./compile.sh \
	
# Download source code
	&&	cd $SOURCE_DIR \
	&&	git clone https://github.com/linux-on-ibm-z/tensorflow \
	&&	cd tensorflow \
	&&	git checkout v1.2.1-s390x \
	
# Configure (without GPU support)
	&&	yes "" | ./configure \
	
# Build TensorFlow
	&&	bazel build -c opt //tensorflow/tools/pip_package:build_pip_package \
	
# Build TensorFlow wheel
	&&	cd $SOURCE_DIR/tensorflow \
	&&	mkdir -p /tensorflow_wheel \
	&&	bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \

# Clean up cache data and remove dependencies which are not required
	&&	apt-get -y remove \
		autoconf \
		automake \
		bzip2 \
		curl \
		g++ \
		git \
		glibc* \
		libcurl3-dev \
		libtool \
		make \
		maven \
		openjdk-8-jdk \
		pkg-config \
		swig \
		unzip \
		vim \
		wget \
		zip \
		zlib1g-dev \
	&&	apt-get autoremove -y \
	&& 	apt autoremove -y \
	&& 	rm -rf $SOURCE_DIR \
	&&	rm -rf /root/.cache/ \
	&& 	apt-get clean \
	&& 	rm -rf /var/lib/apt/lists/*	
	
VOLUME /tensorflow_wheel

# End of Dockerfile	
