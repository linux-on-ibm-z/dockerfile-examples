# © Copyright IBM Corporation 2024, 2026.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for Bazel version 9.2.0 ####################################
#
# To build a Bazel image from the directory containing this Dockerfile:
# (assuming that the file is named Dockerfile):
#   docker build -t <image_name> .
#
# For information on running the container see:
#   https://bazel.build/docs/bazel-container
#
############################################################################################################

FROM s390x/ubuntu:22.04 AS base_image

RUN --mount=source=install_packages.sh,target=/mnt/install_packages.sh,type=bind \
    /mnt/install_packages.sh

FROM base_image AS builder

WORKDIR /var/bazel

RUN mkdir build \
&& cd build \
&& curl -o install_bazel.sh https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Bazel/9.2.0/build_bazel.sh \
&& chmod +x ./install_bazel.sh \
&& ./install_bazel.sh -y \
&& chmod +x /var/bazel/build/bazel/bazel-bin/src/bazel

FROM base_image

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/open-source/)"

RUN useradd --system --create-home --home-dir=/home/ubuntu --shell=/bin/bash --gid=root --groups=sudo --uid=1000 ubuntu
USER ubuntu
WORKDIR /home/ubuntu
COPY --from=builder /var/bazel/build/bazel/bazel-bin/src/bazel /usr/local/bin/bazel
ENTRYPOINT ["/usr/local/bin/bazel"]
