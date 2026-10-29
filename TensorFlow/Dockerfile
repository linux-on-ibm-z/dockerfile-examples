# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.21.0 #########
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
#
# Reference:
# https://www.tensorflow.org/
# https://github.com/tensorflow/tensorflow
#
##################################################################################

FROM ubuntu:22.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget sudo xxd \
    && wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.21.0/build_tensorflow.sh \
    && bash build_tensorflow.sh -y -p 3.10
# End of builder stage

# Base Image
FROM ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip python3-dev build-essential ninja-build pkg-config \
    libhdf5-dev gfortran libopenblas-dev \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && mkdir -p /tensorflow_wheel

# COPY the wheel from builder stage
COPY --from=builder /tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow-2.21.0*-cp*-cp*-linux_s390x.whl /tensorflow_wheel/

# Install the wheel
RUN pip3 install --no-cache-dir /tensorflow_wheel/tensorflow-2.21.0*-cp*-cp*-linux_s390x.whl \
    && rm -f /tensorflow_wheel/*.whl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
CMD ["bash", "-c", "source /etc/bash.bashrc"]
# End of Dockerfile
