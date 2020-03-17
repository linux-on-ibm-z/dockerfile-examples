# © Copyright IBM Corporation 2017, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.0.0 #########
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
FROM s390x/ubuntu:18.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH=$SOURCE_DIR/bazel/output/:/usr/local/go/bin:$PATH TF_ENABLE_XLA=0 \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
                                openjdk-11-jdk \
                                python3-pip \
                                python3-virtualenv \
                                python3-numpy \
                                swig \
                                python3-dev \
                                libcurl3-dev \
                                python3-mock \
                                python3-scipy \
                                bzip2 \
                                python3-sklearn \
                                libhdf5-dev \
                                git \
                                patch \
                                libssl-dev \
                   && pip3 install \
                                wheel \
                                numpy==1.16.2 \
                                future \
                                backports.weakref \
                                portpicker \
                                futures \
                                enum34 \
                                keras_preprocessing \
                                keras_applications \
                                h5py \
                                tensorflow_estimator \
                                grpcio\
# commenting force link         
# &&             ln -sf /usr/bin/python3 /usr/bin/python \
# Install Go
                   &&           mkdir -p $SOURCE_DIR && cd $SOURCE_DIR \
                   &&           wget https://dl.google.com/go/go1.13.3.linux-s390x.tar.gz \
                   &&           tar -C /usr/local -xzf go1.13.3.linux-s390x.tar.gz  \
                   &&           go version  \
# Build Bazel
                   &&           cd $SOURCE_DIR \
                   &&           mkdir bazel \
                   &&           cd bazel \
                   &&           wget https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-dist.zip \
                   &&           unzip bazel-0.26.1-dist.zip \
                   &&           chmod -R +w . \
# Add patch to resolve java oom issue
                   &&           sed -i "130s/-classpath/-J-Xms1g -J-Xmx1g -classpath/" scripts/bootstrap/compile.sh \
                   &&           env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh \
# Download source code
                   &&           cd $SOURCE_DIR \
                   &&           git clone https://github.com/linux-on-ibm-z/tensorflow.git \
                   &&           cd tensorflow \
                   &&           git checkout v2.0.0-s390x \
# Configure
                   &&           yes "" | ./configure \
# Build TensorFlow
                   &&           bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build  --define=tensorflow_mkldnn_contraction_kernel=0 //tensorflow/tools/pip_package:build_pip_package \

# Build TensorFlow wheel
                   &&           cd $SOURCE_DIR/tensorflow \
                   &&           mkdir -p /tensorflow_wheel \
                   &&           bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
                   &&           apt-get -y remove \
                                bzip2 \
                                git \
                                make \
                                maven \
                                unzip \
                                wget \
                                zip \
                   &&           apt-get autoremove -y \
                   &&           apt autoremove -y \
                   &&           rm -rf $SOURCE_DIR \
                   &&           rm -rf /root/.cache/ \
                   &&           apt-get clean \
                   &&           rm -rf /var/lib/apt/lists/* 
#End of builder stage

# Base Image
FROM s390x/ubuntu:18.04
 
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"
ENV SOURCE_DIR=/tmp/source
ENV PATH=$SOURCE_DIR/bazel/output/:/usr/local/go/bin:$PATH TF_ENABLE_XLA=0 \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                                pkg-config \
				python3-pip \
				python3-virtualenv \
                                python3-numpy \
                                python3-dev \
                                python3-mock \
                                python3-scipy \
                                python3-sklearn \
                                libhdf5-dev \
                                libssl-dev \
                   && pip3 install \
                                wheel \
                                numpy==1.16.2 \
                                future \
                                backports.weakref \
                                portpicker \
                                futures \
                                enum34 \
                                keras_preprocessing \
                                keras_applications \
                                h5py \
                                tensorflow_estimator \
                                grpcio \
                   && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.0.0-cp*-linux_s390x.whl /tensorflow_wheel
# Install the wheel
RUN pip3 install /tensorflow_wheel/tensorflow-2.0.0-cp*-linux_s390x.whl

VOLUME /tensorflow_wheel

# End of Dockerfile
