# © Copyright IBM Corporation 2022, 2023.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################################### Dockerfile for Bazel version 6.3.2 ####################################
#
# To build a Bazel image from the directory containing this Dockerfile:
# (assuming that the file is named Dockerfile):
#   docker build -t <image_name> .
#
# For information on running the container see:
#   https://bazel.build/docs/bazel-container
#
############################################################################################################

FROM s390x/ubuntu:20.04 AS base_image

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

WORKDIR /var/bazel

COPY install_packages.sh /var/bazel/

RUN chmod +x install_packages.sh && ./install_packages.sh

FROM base_image AS builder

COPY install_bazel.sh /var/bazel/

RUN chmod +x install_bazel.sh && ./install_bazel.sh

FROM base_image

LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

RUN useradd --system --create-home --home-dir=/home/ubuntu --shell=/bin/bash --gid=root --groups=sudo --uid=1000 ubuntu
USER ubuntu
WORKDIR /home/ubuntu
COPY --from=builder /var/bazel/bazel /usr/local/bin/bazel
ENTRYPOINT ["/usr/local/bin/bazel"]
