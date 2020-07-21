# © Copyright IBM Corporation 2017, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.2.0 #########
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
# docker run --name <container_name> -it -p 8888:8888 <image>

# To copy TensorFlow wheel file :
# docker cp <container_id>:/tensorflow_wheel <path_on_host>
#
# You can install TensorFlow wheel file using pip3 install
#
# Reference:
# https://www.tensorflow.org/
# http://bazel.io/
# https://github.com/tensorflow/tensorflow
#
##################################################################################

# Base Image
FROM ubuntu:18.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=$SOURCE_ROOT/bazel/output/:$PATH \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True PATCH="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.2.0/patch" JTOOLS=$SOURCE_ROOT/remote_java_tools_linux
# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
								wget \
								curl \
								libhdf5-dev \
								python3-dev \
								python3-pip \
								pkg-config \
								unzip \
								openjdk-11-jdk \
								zip \
								libssl-dev \
								git \
								python3-numpy \
								libblas-dev  \
								liblapack-dev \
								python3-scipy \
								gfortran \
								swig \
								cython3 \
					&& ldconfig \
					&& pip3 install --no-cache-dir \
								numpy==1.16.2 \
								future \
								wheel \
								backports.weakref \
								portpicker \
								futures \
								enum34 \
								keras_preprocessing \
								keras_applications \
								h5py \
								tensorflow_estimator \
								setuptools \
								pybind11 \
								grpcio \
					&& ln -sf /usr/bin/python3 /usr/bin/python \
# Build Bazel
					&& mkdir -p $SOURCE_ROOT \
					&& cd $SOURCE_ROOT \
					&& mkdir bazel \
					&& cd bazel \
					&& wget https://github.com/bazelbuild/bazel/releases/download/2.0.0/bazel-2.0.0-dist.zip \
					&& unzip bazel-2.0.0-dist.zip \
					&& chmod -R +w . \
					&& curl -sSL $PATCH/patch1.diff | patch -p1 \
					&& curl -sSL $PATCH/patch2.diff | patch -Np0 --ignore-whitespace \
# Add patch to resolve java oom issue
					&& sed -i "152s/-classpath/-J-Xms1g -J-Xmx1g -classpath/" scripts/bootstrap/compile.sh \
					&& env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh \
# Patch Bazel tools 
					&& cd $SOURCE_ROOT/bazel \
					&& bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build --host_javabase="@local_jdk//:jdk" //:bazel-distfile \
					&& mkdir -p $JTOOLS && cd $JTOOLS \
					&& unzip $SOURCE_ROOT/bazel/derived/distdir/java_tools_javac11_linux-v7.0.zip \
					&& curl -sSL $PATCH/tools.diff | patch -p1 \
# Download source code
					&& cd $SOURCE_ROOT \
					&& git clone https://github.com/linux-on-ibm-z/tensorflow.git \
					&& cd tensorflow \
					&& git checkout v2.2.0-s390x \
# Configure
					&& yes "" | ./configure \
# Build TensorFlow
					&& bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build //tensorflow/tools/pip_package:build_pip_package \
# Build TensorFlow wheel
					&& cd $SOURCE_ROOT/tensorflow \
					&& mkdir -p /tensorflow_wheel \
					&& bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
# Cleanup
					&& apt-get -y remove \
							bzip2 \
							git \
							make \
							unzip \
							wget \
							zip \
					&& apt-get autoremove -y \
					&& apt autoremove -y \
					&& rm -rf $SOURCE_ROOT \
					&& rm -rf /root/.cache/ \
					&& apt-get clean \
					&& rm -rf /var/lib/apt/lists/* 
#End of builder stage

# Base Image
FROM ubuntu:18.04
 
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV SOURCE_ROOT=/tmp/source
ENV PATH=$SOURCE_ROOT/bazel/output/:$PATH \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
								libhdf5-dev \
								python3-dev \
								python3-pip \
								pkg-config \
								libssl-dev \
								python3-numpy \
								libblas-dev  \
								liblapack-dev \
								python3-scipy \
								gfortran \
								swig \
								cython3 \
					&& ldconfig \
					&& pip3 install --no-cache-dir \
				                numpy==1.16.2 \
								future \
								wheel \
								backports.weakref \
								portpicker \
								futures \
								enum34 \
								keras_preprocessing \
								keras_applications \
								h5py \
								tensorflow_estimator \
								grpcio \
					&& ln -sf /usr/bin/python3 /usr/bin/python \
					&& mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.2.0-cp*-linux_s390x.whl /tensorflow_wheel
# Install the wheel
RUN pip3 install /tensorflow_wheel/tensorflow-2.2.0-cp*-linux_s390x.whl

VOLUME /tensorflow_wheel

# End of Dockerfile
