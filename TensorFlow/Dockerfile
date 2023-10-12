# © Copyright IBM Corporation 2017, 2023
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.11.0 #########
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
ENV PATCH_URL=https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.11.0/patch \
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
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.22.4 \
    wheel \
    scipy==1.7.3 \
    portpicker \
    protobuf==3.13.0 \
    opt_einsum \    
    packaging \
    requests \
    psutil \
    setuptools==59.5.0 \
    && pip3 install --no-cache-dir \
    grpcio \
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
# Build Bazel
    && cd $SOURCE_ROOT \
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/5.3.2/build_bazel.sh \
	&& sed -i 's/5.3.2/5.3.0/g' build_bazel.sh \
	&& sed -i 's#Bazel/${PACKAGE_VERSION}/patch#Bazel/5.3.2/patch#g' build_bazel.sh \
	&& sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_bazel.sh \
    && bash build_bazel.sh -y \
    && cp $SOURCE_ROOT/bazel/output/bazel /usr/local/bin/bazel \
# Download source code
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/tensorflow \
    && cd tensorflow \
    && git checkout v2.11.0 \
    && curl -o tf_v2.11.0.patch ${PATCH_URL}/tf_v2.11.0.patch \
    && patch -p1 < tf_v2.11.0.patch \
	&& cp ${SOURCE_ROOT}/icu/icu4c/source/data/out/tmp/icu_conversion_data_big_endian.c.gz.* third_party/icu/data/ \
# Configure
    && yes "" | ./configure || true \
# Build TensorFlow
    && bazel build //tensorflow/tools/pip_package:build_pip_package \
# Build tensorflow_io_gcs_filesystem wheel
    && sudo pip install --upgrade pip \
    && cd $SOURCE_ROOT \
    && git clone https://github.com/tensorflow/io.git \
    && cd io/ \
    && git checkout v0.23.1 \
    && python3 setup.py -q bdist_wheel --project tensorflow_io_gcs_filesystem \
    && cd dist \
    && sudo pip3 install ./tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl \
# Build TensorFlow wheel
    && cd $SOURCE_ROOT/tensorflow \
    && mkdir -p /tensorflow_wheel \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tensorflow_wheel \
    && cp $SOURCE_ROOT/io/dist/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl /tensorflow_wheel \
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
ENV PYTHON_BIN_PATH=/usr/bin/python3 GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True
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
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 40 \
    && ldconfig \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    numpy==1.22.4 \
    wheel \
    scipy==1.7.3 \
    portpicker \
    protobuf==3.13.0 \
    opt_einsum \   
    packaging \
    requests \
    setuptools==59.5.0 \
    && pip3 install --no-cache-dir \
    grpcio \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tensorflow_wheel
# COPY the wheel from builder stage
COPY --from=builder /tensorflow_wheel/tensorflow-2.11.0-cp*-linux_s390x.whl /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl /tensorflow_wheel/
# Install the wheel
RUN pip3 install --no-cache-dir /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.23.1-cp*-cp*-linux_s390x.whl \
    && pip3 install --no-cache-dir /tensorflow_wheel/tensorflow-2.11.0-cp*-linux_s390x.whl \
    && rm -f /tensorflow_wheel/*.whl \
    && rm -rf /root/.cache/

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
CMD ["bash", "-c", "source /etc/bash.bashrc"]
# End of Dockerfile
