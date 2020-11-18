# © Copyright IBM Corporation 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow Serving version 2.2.0 #########
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
# To start container from image & start an application in production mode
# docker run --name <container_name> -d <image>
# docker run --name <container_name> -it -p 8888:8888 <image>
#
# To copy TensorFlow wheel file :
# docker cp <container_id>:/tensorflow_wheel <path_on_host>
# To copy TensorFlow Serving wheel file :
# docker cp <container_id>:/tfs_wheel <path_on_host>
#
# To train saved models, you can git pull serving and run docker image with model.
# git clone -b 2.2.0 https://github.com/tensorflow/serving
# python tensorflow_serving/example/mnist_saved_model.py  /tmp/mnist
#
# docker run -p 8500:8500 --mount type=bind,source=/tmp/mnist,target=/models/mnist -e MODEL_NAME=mnist -t <image> &
#
# You can install TensorFlow wheel and Tensorflow Serving wheel file using pip3 install
#
# Reference:
# https://www.tensorflow.org/tfx/guide/serving
# http://bazel.io/
# https://github.com/tensorflow/serving
#
##################################################################################

# Base Image
FROM ubuntu:20.04 AS builder
# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV SOURCE_ROOT=/tmp/source
ENV PATH=$SOURCE_ROOT/bazel/output/:$PATH \
PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True PATCH="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.2.0/patch" JTOOLS=$SOURCE_ROOT/remote_java_tools_linux \
PATCH_URL="https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/TensorflowServing/2.2.0/patch"
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
								autotools-dev \
								automake \
								libtool \
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
					&& wget -O tf_patch.diff $PATCH_URL/tf_patch.diff \
					&& git apply tf_patch.diff \
# Configure
                                        && yes "" | ./configure \
# Build TensorFlow
                                        && bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build --jobs=50 //tensorflow/tools/pip_package:build_pip_package \
# Build TensorFlow wheel
					&& cd $SOURCE_ROOT/tensorflow \
					&& mkdir -p /tensorflow_wheel \
                                        && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \

#Install BoringSSL
					&& cd $SOURCE_ROOT \
					&& wget https://github.com/google/boringssl/archive/7f634429a04abc48e2eb041c81c5235816c96514.tar.gz \
					&& tar -zxvf 7f634429a04abc48e2eb041c81c5235816c96514.tar.gz \
					&& mv boringssl-7f634429a04abc48e2eb041c81c5235816c96514/ boringssl/ \
					&& cd boringssl/ \
					&& sed -i '/set(ARCH "ppc64le")/a \elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "s390x")\n\ set(ARCH "s390x")' src/CMakeLists.txt \
					&& sed -i '/OPENSSL_PNACL/a \#elif defined(__s390x__)\n\#define OPENSSL_64_BIT' src/include/openssl/base.h \


#Install Tensorflow Serving
					&& mkdir $SOURCE_ROOT/serving && cd $SOURCE_ROOT/serving \
					&& git clone -b 2.2.0 https://github.com/tensorflow/serving . \
					&& wget -O tfs_patch.diff $PATCH_URL/tfs.patch \
					&& sed -i "s?source_root?$SOURCE_ROOT?" tfs_patch.diff \
					&& git apply tfs_patch.diff \


# Build, and install TensorFlow Serving
					&& bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build --color=yes --curses=yes  --local_resources 5000,1.0,1.0 --host_javabase="@local_jdk//:jdk" --verbose_failures --output_filter=DONT_MATCH_ANYTHING -c opt tensorflow_serving/model_servers:tensorflow_model_server \

					&& bazel --host_jvm_args="-Xms1024m" --host_jvm_args="-Xmx2048m" build  --verbose_failures //tensorflow_serving/tools/pip_package:build_pip_package \

					&& cd $SOURCE_ROOT/serving \
					&& mkdir /tfs_wheel \
					&& bazel-bin/tensorflow_serving/tools/pip_package/build_pip_package /tfs_wheel \
					&& cp bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server /tfs_wheel \

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
                                                                python3-numpy \
                                                                libblas-dev  \
                                                                liblapack-dev \
                                                                python3-scipy \
                                                                gfortran \
                                                                swig \
                                                                cython3 \
								autotools-dev \
								automake \
								libtool \
								git \
								curl \
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
                                        && mkdir -p /tfs_wheel \
                                        && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tfs_wheel/* /tfs_wheel/
COPY --from=builder /tensorflow_wheel/* /tensorflow_wheel/
# Install the wheel
RUN ls /tfs_wheel && cp /tfs_wheel/tensorflow_model_server /usr/local/bin/ \
    && pip3 install /tensorflow_wheel/tensorflow-2.2.0-cp*-linux_s390x.whl \
    && pip3 install /tfs_wheel/tensorflow_serving_api-*.whl

VOLUME /tfs_wheel /usr/local/bin/

# End of Dockerfile
