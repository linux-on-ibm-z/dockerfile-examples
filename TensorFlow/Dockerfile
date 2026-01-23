# © Copyright IBM Corporation 2017, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow version 2.20.0 #########
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

FROM ubuntu:22.04 as builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget sudo \
    && wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Tensorflow/2.20.0/build_tensorflow.sh \
    && bash build_tensorflow.sh -y -p 3.11
# End of builder stage

# Base Image
FROM ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"
ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=True

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libjpeg-dev libhdf5-dev gfortran libopenblas-dev curl wget sudo \
    && mkdir -p /tensorflow_wheel \
# Setup Python
    && wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/3.11.4/build_python3.sh \
    && sed -i 's/apt-get install/DEBIAN_FRONTEND=noninteractive apt-get install/g' build_python3.sh \
    && bash build_python3.sh -y \
    && sudo update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 40 \
    && sudo update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.11 50  \
    && rm -f build_python3.sh \
    && rm -rf python*
	
# COPY the wheel from builder stage
COPY --from=builder /tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow_cpu-2.20.0*-cp*-cp*-linux_s390x.whl /tensorflow_wheel/

# Install the wheel
RUN pip3 install --no-cache-dir /tensorflow_wheel/tensorflow_cpu-2.20.0*-cp*-cp*-linux_s390x.whl \
    && rm -f /tensorflow_wheel/*.whl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
CMD ["bash", "-c", "source /etc/bash.bashrc"]
# End of Dockerfile
