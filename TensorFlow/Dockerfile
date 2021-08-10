# © Copyright IBM Corporation 2017, 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.5.0 #########
#
# This Dockerfile builds a basic installation of TensorFlow.
#
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To start container from image & start an application in production mode
# docker run --name <container_name> -it <image> bash
# docker run --name <container_name> -it -p 8888:8888 <image>

# Reference:
# https://www.tensorflow.org/
# http://bazel.io/
# https://github.com/tensorflow/tensorflow
#
##################################################################################

# Base Image
FROM ubuntu:20.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=$SOURCE_ROOT/bazel/output/:$PATH \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True JTOOLS=$SOURCE_ROOT/remote_java_tools_linux
# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    curl \
    sudo \
    libhdf5-dev \
    python3-dev \
    python3-pip \
    pkg-config \
    unzip \
    openjdk-11-jdk \
    zip \
    libssl-dev \
    git \
    libblas-dev  \
    liblapack-dev \
    gfortran \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.19.5 \
    wheel \
    scipy==1.6.3 \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
# Build Bazel
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/3.7.2/build_bazel.sh \
	&& sed -i "s/\"ubuntu-18.04\"/\"ubuntu-18.04\" | \"ubuntu-20.04\"/g" build_bazel.sh \
	&& bash build_bazel.sh -y \
# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/linux-on-ibm-z/tensorflow.git \
    && cd tensorflow \
    && git checkout v2.5.0-s390x \
# Configure
    && yes "" | ./configure || true \
# Build TensorFlow
    && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build //tensorflow/tools/pip_package:build_pip_package \
# Build TensorFlow wheel
    && cd $SOURCE_ROOT/tensorflow \
    && mkdir -p /tensorflow_wheel \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
# Cleanup
    && apt-get -y remove \
    git \
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
FROM ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

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
    libblas-dev  \
    liblapack-dev \
    gfortran \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.19.5 \
    wheel \
    scipy==1.6.3 \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
    && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.5.0-cp*-linux_s390x.whl /tensorflow_wheel
# Install the wheel
RUN pip3 install /tensorflow_wheel/tensorflow-2.5.0-cp*-linux_s390x.whl

VOLUME /tensorflow_wheel

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
# End of Dockerfile
