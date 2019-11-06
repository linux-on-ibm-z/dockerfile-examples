# © Copyright IBM Corporation 2017, 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 1.15.0 #########
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
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH=$PATH:$SOURCE_DIR/bazel/output/:$SOURCE_DIR/jdk-11.0.5+10/bin JAVA_HOME=$SOURCE_DIR/jdk-11.0.5+10 TF_NEED_GCP=0 TF_NEED_HDFS=0 \
                TF_NEED_CUDA=0 TF_NEED_MKL=0 TF_NEED_OPENCL=0 TF_NEED_VERBS=0 TF_NEED_S3=0 \
                TF_NEED_KAFKA=0 TF_NEED_AWS=0 TF_ENABLE_XLA=0 TF_CUDA_CLANG=0 TF_NEED_ROCM=0 \
                PYTHON_BIN_PATH=/usr/bin/python GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
		
# Install dependencies
RUN       apt-get update && apt-get install -y \
                                pkg-config \
                                zip \
                                g++ \
                                zlib1g-dev \
                                unzip \
                                git \
                                vim \
                                tar \
                                wget \
                                automake \
                                autoconf \
                                libtool \
                                make \
                                curl \
                                maven \
                                python3-pip \
                                python3-virtualenv \
                                swig \
                                python3-dev \
                                libcurl3-dev \
                                python3-mock \
                                python3-scipy \
                                bzip2 \
				libhdf5-dev \
				git \                              
                                patch \
                                libhdf5-dev \
                                libssl-dev \
		&&     apt-get install --no-install-recommends -y python3-sklearn \
                &&     pip3 install \
                                wheel \
                                numpy==1.16.2 \
				future \
				backports.weakref \
				portpicker \
				futures==2.2.0 \
				enum34 \
				keras_preprocessing \
				keras_applications \
				h5py \
				tensorflow_estimator==1.15.1 \
                                grpcio==1.24.3 \
# Install OpenJDK 11
                &&      mkdir -p $SOURCE_DIR && cd $SOURCE_DIR && wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.5%2B10/OpenJDK11U-jdk_s390x_linux_hotspot_11.0.5_10.tar.gz \
                &&     tar -xvf OpenJDK11U-jdk_s390x_linux_hotspot_11.0.5_10.tar.gz \
                &&     ln -sf /usr/bin/python3 /usr/bin/python \
# Build Bazel
                &&         cd $SOURCE_DIR \
                &&         mkdir bazel \
                &&         cd bazel \
                &&         wget https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-dist.zip \
                &&         unzip bazel-0.26.1-dist.zip \
                &&         chmod -R +w . \
# Add patch to resolve java oom issue
                &&         sed -i "130s/-classpath/-J-Xms1g -J-Xmx1g -classpath/" scripts/bootstrap/compile.sh \
                &&         env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh \
# Download source code
                &&         cd $SOURCE_DIR \
                &&         git clone https://github.com/linux-on-ibm-z/tensorflow \
                &&         cd tensorflow \
                &&         git checkout v1.15.0-s390x \
# Configure (without GPU support)
                &&         yes "" | ./configure \
# Build TensorFlow
                &&         bazel --host_jvm_args="-Xms512m" --host_jvm_args="-Xmx1024m" build -c opt //tensorflow/tools/pip_package:build_pip_package \
# Build TensorFlow wheel
                &&         cd $SOURCE_DIR/tensorflow \
                &&         mkdir -p /tensorflow_wheel \
                &&         bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
                &&         apt-get -y remove \
                                bzip2 \
                                git \
                                make \
                                maven \
                                unzip \
                                wget \
                                zip \
                &&         apt-get autoremove -y \
                &&         apt autoremove -y \
                &&         rm -rf $SOURCE_DIR \
                &&         rm -rf /root/.cache/ \
                &&         apt-get clean \
                &&         rm -rf /var/lib/apt/lists/*				

VOLUME /tensorflow_wheel

# End of Dockerfile 
