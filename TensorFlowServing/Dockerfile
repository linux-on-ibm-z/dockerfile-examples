# © Copyright IBM Corporation 2020, 2021
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow Serving version 2.4.0 #########
#
# This Dockerfile builds a basic installation of TensorFlow Serving.
#
# TensorFlow Serving is a flexible, high-performance serving system for machine learning models, designed for production environments.
# TensorFlow Serving makes it easy to deploy new algorithms and experiments, while keeping the same server architecture and APIs.
# TensorFlow Serving provides out-of-the-box integration with TensorFlow models, but can be easily extended to serve other types of models and data.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To copy TensorFlow Serving binary file :
# docker cp <container_id>:/usr/bin/tensorflow_model_server <path_on_host>
#
# Please run the following command as an example of the TensorFlow Serving image:
#
# git clone -b 2.4.0 https://github.com/tensorflow/serving
# TESTDATA="$(pwd)/tensorflow_serving/servables/tensorflow/testdata"
# docker run -t --rm -p 8501:8501 \
#   -v "$TESTDATA/saved_model_half_plus_two_cpu:/models/half_plus_two" \
#   -e MODEL_NAME=half_plus_two <image_name> &
#
# Query the model using the predict API
# curl -d '{"instances": [1.0, 2.0, 5.0]}' \
#   -X POST http://localhost:8501/v1/models/half_plus_two:predict
#
# Returns => { "predictions": [2.5, 3.0, 4.5] }
#
# For more direct usage of the image, please refer to the last reference link below
#
# You can also install TensorFlow wheel and Tensorflow Serving API using pip3 install
#
# Reference:
# https://www.tensorflow.org/tfx/guide/serving
# http://bazel.io/
# https://github.com/tensorflow/serving
# https://github.com/tensorflow/serving/blob/master/tensorflow_serving/g3doc/docker.md
#
##################################################################################

# Base Image
FROM ubuntu:20.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source
ENV PATH=$SOURCE_ROOT/bazel/output/:$PATH \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True \
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/TensorflowServing/2.4.0/patch"

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
    cython3 \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy \
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
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/3.4.1/build_bazel.sh \
    && sed -i "s/\"ubuntu-18.04\"/\"ubuntu-18.04\" | \"ubuntu-20.04\"/g" build_bazel.sh \
    && bash build_bazel.sh -y \
    && mv bazel-s390x/ bazel/ \

# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/linux-on-ibm-z/tensorflow.git \
    && cd tensorflow \
    && git checkout v2.4.0-s390x \
    && curl -o tf_patch.diff $PATCH_URL/tf_patch.diff \
    && git apply tf_patch.diff \

# Configure
    && yes "" | ./configure \

# Build TensorFlow
    && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build //tensorflow/tools/pip_package:build_pip_package \

# Build and install TensorFlow wheel
    && cd $SOURCE_ROOT/tensorflow \
    && mkdir -p /tensorflow_wheel \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
    && pip3 install /tensorflow_wheel/tensorflow-2.4.0-cp*-linux_s390x.whl \

# Install BoringSSL
    && cd $SOURCE_ROOT \
    && wget https://github.com/google/boringssl/archive/7f634429a04abc48e2eb041c81c5235816c96514.tar.gz \
    && tar -zxvf 7f634429a04abc48e2eb041c81c5235816c96514.tar.gz \
    && mv boringssl-7f634429a04abc48e2eb041c81c5235816c96514/ boringssl/ \
    && cd boringssl/ \
    && sed -i '/set(ARCH "ppc64le")/a \elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "s390x")\n\ set(ARCH "s390x")' src/CMakeLists.txt \
    && sed -i '/OPENSSL_PNACL/a \#elif defined(__s390x__)\n\#define OPENSSL_64_BIT' src/include/openssl/base.h \

# Install Tensorflow Serving
    && mkdir $SOURCE_ROOT/serving && cd $SOURCE_ROOT/serving \
    && git clone -b 2.4.0 https://github.com/tensorflow/serving . \
    && curl -o tfs_patch.diff $PATCH_URL/tfs_patch.diff \
    && sed -i "s?source_root?$SOURCE_ROOT?" tfs_patch.diff \
    && git apply tfs_patch.diff \

# Build, and install TensorFlow Serving
    && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build --host_javabase="@local_jdk//:jdk" -c opt tensorflow_serving/model_servers:tensorflow_model_server \

    && cd $SOURCE_ROOT/serving \
    && mkdir /tfs_bin \
    && cp bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /tfs_bin \

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

FROM ubuntu:20.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install TF Serving pkg
COPY --from=builder /tfs_bin/tensorflow_model_server /usr/bin/tensorflow_model_server

# Expose ports
# gRPC
EXPOSE 8500

# REST
EXPOSE 8501

# Set where models should be stored in the container
ENV MODEL_BASE_PATH=/models
RUN mkdir -p ${MODEL_BASE_PATH}

# The only required piece is the model name in order to differentiate endpoints
ENV MODEL_NAME=model

# Create a script that runs the model server so we can use environment variables
# while also passing in arguments from the docker command line
RUN echo '#!/bin/bash \n\n\
tensorflow_model_server --port=8500 --rest_api_port=8501 \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]

# End of Dockerfile
