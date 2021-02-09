# © Copyright IBM Corporation 2017, 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.4.0 #########
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
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True PATCH="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.4.0/patch" JTOOLS=$SOURCE_ROOT/remote_java_tools_linux
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
    libblas-dev  \
    liblapack-dev \
    gfortran \
    cython3 \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.19.5 \
    wheel \
    scipy \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && ln -sf /usr/bin/python3 /usr/bin/python \
# Build Bazel
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && mkdir bazel \
    && cd bazel \
    && wget https://github.com/bazelbuild/bazel/releases/download/3.1.0/bazel-3.1.0-dist.zip \
    && unzip bazel-3.1.0-dist.zip \
    && chmod -R +w . \
    && curl -sSL $PATCH/patch.diff | patch -p1 \
# Add patch to resolve java oom issue
    && sed -i "152s/-classpath/-J-Xms1g -J-Xmx1g -classpath/" scripts/bootstrap/compile.sh \
    && env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh \
# Patch Bazel tools
    && cd $SOURCE_ROOT/bazel \
    && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build --host_javabase="@local_jdk//:jdk" //:bazel-distfile \
    && mkdir -p $JTOOLS && cd $JTOOLS \
    && unzip $SOURCE_ROOT/bazel/derived/distdir/java_tools_javac11_linux-v8.0.zip \
    && curl -sSL $PATCH/tools.diff | patch -p1 \
# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/linux-on-ibm-z/tensorflow.git \
    && cd tensorflow \
    && git checkout v2.4.0-s390x \
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
    cython3 \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.19.5 \
    wheel \
    scipy \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.4.0-cp*-linux_s390x.whl /tensorflow_wheel
# Install the wheel
RUN pip3 install /tensorflow_wheel/tensorflow-2.4.0-cp*-linux_s390x.whl

VOLUME /tensorflow_wheel

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
# End of Dockerfile
