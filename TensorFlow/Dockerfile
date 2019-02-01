# © Copyright IBM Corporation 2017, 2019
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 1.12.0 #########
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

ENV SOURCE_DIR=/tmp/source
ENV PATH=$PATH:$SOURCE_DIR/bazel/output/ TF_NEED_IGNITE=0 TF_NEED_GCP=0 \
                TF_NEED_CUDA=0 TF_ENABLE_XLA=0 TF_NEED_GDR=0 TF_NEED_VERBS=0 TF_NEED_MPI=0 \
                TF_NEED_OPENCL_SYCL=0 TF_SET_ANDROID_WORKSPACE=0 TF_NEED_GCP=0 TF_CUDA_CLANG=0 TF_NEED_ROCM=0 \
                PYTHON_BIN_PATH=/usr/bin/python2 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
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
                                openjdk-8-jdk \
                                python-pip \
                                python-virtualenv \
                                swig \
                                python-dev \
                                libcurl3-dev \
                                python-mock \
                                python-scipy \
                                bzip2 \
                                glibc* \
                                python-sklearn \
                                python-numpy \
                                patch \
                                libhdf5-dev \
                                libssl-dev \
                &&     pip install \
                                wheel \
                                backports.weakref \
                                portpicker \
                                futures \
                                grpc \
                                enum34 \
                &&  pip install numpy==1.13.3 \
		        &&  pip install keras_applications==1.0.5 --no-deps \
		        &&  pip install keras_preprocessing==1.0.3 --no-deps \
		        &&  pip install keras \
		        &&  pip install grpcio \
# Build Bazel
                &&         mkdir -p $SOURCE_DIR \
                &&         cd $SOURCE_DIR \
                &&         mkdir bazel \
                &&         cd bazel \
                &&         wget https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel-0.15.0-dist.zip \
                &&         unzip bazel-0.15.0-dist.zip \
                &&         chmod -R +w . \
# Add patch to resolve java oom issue
                &&         sed -i '117d' scripts/bootstrap/compile.sh \
                &&         sed -i '117 i run "${JAVAC}" -J-Xms1g -J-Xmx1g -classpath "${classpath}" -sourcepath "${sourcepath}" \\' scripts/bootstrap/compile.sh \
                &&         bash ./compile.sh \
# Download source code
                &&         cd $SOURCE_DIR \
                &&         git clone https://github.com/linux-on-ibm-z/tensorflow \
                &&         cd tensorflow \
                &&         git checkout v1.12.0-s390x \
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
