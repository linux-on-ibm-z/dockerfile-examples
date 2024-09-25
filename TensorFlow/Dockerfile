# © Copyright IBM Corporation 2017, 2024.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.16.1 #########
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
ENV PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.16.1/patch
ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True TF_SYSTEM_LIBS=boringssl
ENV TF_NEED_CLANG=0 TF_NEED_OPENCL_SYCL=0 TF_NEED_CUDA=0 TF_NEED_MKL=0 TF_PYTHON_VERSION=3.11 PYTHON_VERSION=3.11.4

COPY tf_v2.16.1.patch $SOURCE_ROOT/

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
        git \
        unzip \
        zip \
        openjdk-11-jdk \
        sudo \
        pkg-config \
        libhdf5-dev \
        libssl-dev \
        libblas-dev \
        liblapack-dev \
        gfortran \
        curl \
        patchelf \
        gcc-10 \
        g++-10 \
	make \
        libopenblas-dev \
        libatlas-base-dev \
        && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 60 \
        && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 60 \
# Build Bazel
    && cd $SOURCE_ROOT \
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/6.4.0/build_bazel.sh \
    && sed -i 's/6.4.0/6.5.0/g' build_bazel.sh \
    && sed -i 's#Bazel/${PACKAGE_VERSION}/patch#Bazel/6.4.0/patch#g' build_bazel.sh \
    && sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_bazel.sh \
    && bash build_bazel.sh -y \
    && cp $SOURCE_ROOT/bazel/output/bazel /usr/local/bin/bazel \
#Setup Python
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/3.11.4/build_python3.sh \
    && sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_python3.sh \
    && bash build_python3.sh -y \
    && sudo update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 40 \
    && sudo update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.11 50 \
#Install pip packages
    && sudo pip3 install --no-cache-dir numpy==1.23.5 wheel packaging requests opt_einsum portpicker protobuf scipy==1.13.0 psutil setuptools==68.2.2 \
    &&  sudo -E pip3 install grpcio \
#Build ICU data
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && git clone --depth 1 --single-branch --branch "release-69-1" https://github.com/unicode-org/icu.git \
    && cd icu/icu4c/source/ \
    && echo '{ "localeFilter": { "filterType": "language", "includelist": ["en"] } }' > filters.json \
    && ICU_DATA_FILTER_FILE=filters.json ./runConfigureICU Linux \
    && make clean && make \
    && find data/out/build/ -name '*pool.res' -print0 | xargs -0 touch \
    && make \
    && cd data/out/tmp \
    && LD_LIBRARY_PATH=../../../lib ../../../bin/genccode "icudt69b.dat" \
    && echo "U_CAPI const void * U_EXPORT2 uprv_getICUData_conversion() { return icudt69b_dat.bytes; }" >> "icudt69b_dat.c" \
    && cp icudt69b_dat.c icu_conversion_data_big_endian.c \
    && gzip icu_conversion_data_big_endian.c \
    && split -a 3 -b 100000 icu_conversion_data_big_endian.c.gz icu_conversion_data_big_endian.c.gz. \
# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/tensorflow \
    && cd tensorflow \
    && git checkout v2.16.1 \
    && curl -o tf_v2.16.1.patch ${PATCH_URL}/tf_v2.16.1.patch \
    && patch -p1 < tf_v2.16.1.patch \
    && cp ${SOURCE_ROOT}/icu/icu4c/source/data/out/tmp/icu_conversion_data_big_endian.c.gz.* third_party/icu/data/ \
# Configure
    && yes "" | ./configure || true \
# Build TensorFlow
    && bazel build --define tflite_with_xnnpack=false //tensorflow/tools/pip_package:build_pip_package \
# Build tensorflow_io_gcs_filesystem wheel
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/io.git \
    && cd io/ \
    && git checkout v0.29.0 \
    && python3 setup.py -q bdist_wheel --project tensorflow_io_gcs_filesystem \
    && cd dist \
    && sudo pip3 install ./tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl \
# Build TensorFlow wheel
    && cd $SOURCE_ROOT/tensorflow \
    && mkdir -p /tensorflow_wheel \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
    && cp $SOURCE_ROOT/io/dist/tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl /tensorflow_wheel \
# Cleanup
    && apt-get -y remove \
    git \
    unzip \
    wget \
    zip \
    && apt-get autoremove -y \
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
ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libhdf5-dev \
    pkg-config \
    libssl-dev \
    libblas-dev  \
    liblapack-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tensorflow_wheel  \
#Setup Python
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/3.11.4/build_python3.sh \
    && sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_python3.sh \
    && bash build_python3.sh -y \
    && sudo update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 40 \
    && sudo update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.11 50
    
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.16.1-cp*-linux_s390x.whl /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl /tensorflow_wheel/
# Install the wheel
RUN pip3 install --no-cache-dir /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl \
    && pip3 install --no-cache-dir /tensorflow_wheel/tensorflow-2.16.1-cp*-linux_s390x.whl \
    && rm -f /tensorflow_wheel/*.whl \
    && rm -rf /root/.cache/
COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
CMD ["bash", "-c", "source /etc/bash.bashrc"]
# End of Dockerfile
