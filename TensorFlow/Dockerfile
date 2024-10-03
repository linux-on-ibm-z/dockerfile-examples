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
#
# Reference:
# https://www.tensorflow.org/
# http://bazel.io/
# https://github.com/tensorflow/tensorflow
#
##################################################################################

FROM ubuntu:22.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget sudo \
    && wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.16.1/build_tensorflow.sh \
    && bash build_tensorflow.sh -y -p 3.11 \
# Cleanup 
    && apt-get autoremove -y \
    && rm -rf /root/.cache/ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# End of builder stage

# Base Image
FROM ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libhdf5-dev \
    pkg-config \
    libssl-dev \
    libblas-dev  \
    liblapack-dev \
    make \
    wget \
    sudo \
    && mkdir -p /tensorflow_wheel  \
# Setup Python
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/3.11.4/build_python3.sh \
    && sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_python3.sh \
    && bash build_python3.sh -y \
    && sudo update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 40 \
    && sudo update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.11 50  
	
# COPY the wheel from builder stage
COPY --from=builder /tmp/tensorflow_wheel/tensorflow-2.16.1-cp*-linux_s390x.whl  /tensorflow_wheel/
COPY --from=builder /io/dist/tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl /tensorflow_wheel/

# Install the wheel
RUN pip3 install --no-cache-dir /tensorflow_wheel/tensorflow_io_gcs_filesystem-0.29.0-cp*-cp*-linux_s390x.whl \
    && pip3 install --no-cache-dir /tensorflow_wheel/tensorflow-2.16.1-cp*-linux_s390x.whl \
    && rm -f /tensorflow_wheel/*.whl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
CMD ["bash", "-c", "source /etc/bash.bashrc"]
# End of Dockerfile
