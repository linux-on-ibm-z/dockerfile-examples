# © Copyright IBM Corporation 2017, 2022
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.9.1 #########
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
# Reference:
# https://www.tensorflow.org/
# http://bazel.io/
# https://github.com/tensorflow/tensorflow
#
##################################################################################

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
    numpy==1.22.3 \
    wheel \
    scipy==1.6.3 \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    packaging \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
# Build Bazel
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/5.1.1/build_bazel.sh \
    && bash build_bazel.sh -y \
# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/tensorflow \
    && cd tensorflow \
    && git checkout v2.9.1 \
    && curl -o build_patch.diff https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.9.1/patch/build_patch.diff \
    && git apply --ignore-whitespace build_patch.diff \
    && sed -i 's/float_t/float/g' tensorflow/stream_executor/tpu/c_api_decl.h \
# Configure
    && yes "" | ./configure || true \
# Build TensorFlow
    && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build  --define=tensorflow_mkldnn_contraction_kernel=0 --define tflite_with_xnnpack=false //tensorflow/tools/pip_package:build_pip_package \
# Build tensorflow_io_gcs_filesystem wheel
    && sudo pip install --upgrade pip \
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/io.git \
    && cd io/ \
    && git checkout v0.23.1 \
    && python3 setup.py -q bdist_wheel --project tensorflow_io_gcs_filesystem \
    && cd dist \
    && sudo pip3 install ./tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl \
#Build libclang wheel
    && cd $SOURCE_ROOT \
    && sudo apt-get install -y cmake \
    && git clone https://github.com/llvm/llvm-project \
    && cd llvm-project \
    && git checkout llvmorg-9.0.1 \
    && mkdir -p build \
    && cd build \
    && cmake ../llvm -DLLVM_ENABLE_PROJECTS=clang -DBUILD_SHARED_LIBS=OFF -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_TARGETS_TO_BUILD=SystemZ -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_CXX_FLAGS_MINSIZEREL="-Os -DNDEBUG -static-libgcc -static-libstdc++ -s" \
    && make libclang -j$(nproc) \
    && cd $SOURCE_ROOT \
    && git clone https://github.com/sighingnow/libclang.git \
    && cd libclang \
    && cp $SOURCE_ROOT/llvm-project/build/lib/libclang.so.9 native/ \
    && cp $SOURCE_ROOT/llvm-project/build/lib/libclang.so native/ \
    && python3 setup.py -q bdist_wheel \
    && cd dist \
    && sudo pip3 install libclang-*-py2.py3-none-any.whl \
# Build TensorFlow wheel
    && cd $SOURCE_ROOT/tensorflow \
    && mkdir -p /tensorflow_wheel \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
    && cp $SOURCE_ROOT/io/dist/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl /tensorflow_wheel \
    && cp $SOURCE_ROOT/libclang/dist/libclang-*-py2.py3-none-any.whl  /tensorflow_wheel \

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
    numpy==1.22.3 \
    wheel \
    scipy==1.6.3 \
    portpicker \
    protobuf==3.13.0 \
    grpcio \
    packaging \
    && pip3 install --no-cache-dir \
    keras_preprocessing --no-deps \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
    && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.9.1-cp*-linux_s390x.whl /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl /tensorflow_wheel/libclang-*-py2.py3-none-any.whl /tensorflow_wheel/
# Install the wheel
RUN pip3 install /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl /tensorflow_wheel/libclang-*-py2.py3-none-any.whl\
    && pip3 install /tensorflow_wheel/tensorflow-2.9.1-cp*-linux_s390x.whl

VOLUME /tensorflow_wheel

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
# End of Dockerfile
