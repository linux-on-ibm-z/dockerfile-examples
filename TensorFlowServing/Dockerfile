# © Copyright IBM Corporation 2020, 2025.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

########## Dockerfile for TensorFlow Serving version 2.18.0 #########
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
# git clone -b 2.18.0 https://github.com/tensorflow/serving
# TESTDATA="$(pwd)/serving/tensorflow_serving/servables/tensorflow/testdata"
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
FROM ubuntu:22.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

ENV SOURCE_ROOT=/tmp/source

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget sudo \
    && mkdir -p $SOURCE_ROOT \
    && cd $SOURCE_ROOT \
    && wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/TensorflowServing/2.18.0/build_tensorflow_serving.sh  \
# Build TensorFlow Serving
    && bash build_tensorflow_serving.sh -y
#End of builder stage

FROM ubuntu:22.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install TF Serving pkg
COPY --from=builder /usr/local/bin/tensorflow_model_server /usr/bin/tensorflow_model_server

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
