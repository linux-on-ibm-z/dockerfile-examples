# © Copyright IBM Corporation 2018, 2020
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
########## Dockerfile for V8 JavaScript version 8.1 #########
#
# This Dockerfile builds a basic installation of V8_JavaScript.
#
# V8 is Google’s open source high-performance JavaScript and WebAssembly engine.
# V8 is written in C++ and is used in Google Chrome, the open source browser from Google.
# V8 can run standalone, or can be embedded into any C++ application.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start V8_JavaScript run the below command:
# docker run --name <container_name> -it <image_name>
#
# Reference:
# https://v8.dev/docs
#
##################################################################################

# Base Image
FROM s390x/ubuntu:18.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
ENV PATH="$SOURCE_DIR/gn/out:$PATH:$SOURCE_DIR/depot_tools"
ENV VPYTHON_BYPASS="manually managed python not supported by chrome operations"

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python curl pkg-config \
                libnss3-dev libcups2-dev git vim libglib2.0-dev \
                libpango1.0-dev libgconf2-dev \
                libgnome-keyring-dev libatk1.0-dev \
                libgtk-3-dev wget clang g++ gcc \
                ninja-build gcc-multilib g++-multilib tzdata \
# Clone depot_tools from the Chromium project, as it contains a number of tools needed to build V8
        && cd $SOURCE_DIR \
        && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git \
# Install gn
        && git clone https://gn.googlesource.com/gn \
        && cd gn \
        && sed -i -e 's/-Wl,--icf=all//g' ./build/gen.py \
        && sed -i -e 's/-lpthread/-pthread/g' ./build/gen.py \
        && python build/gen.py \
        && ninja -C out \
# Obtain the V8 source code
        && cd $SOURCE_DIR \
        && fetch v8 \
        && cd v8/ \
        && git checkout 8.1.307.32 \
        && gclient sync \
        && mkdir out/s390x.release \
        && gn gen out/s390x.release --args='is_component_build=false target_cpu="s390x" v8_target_cpu="s390x" \
           use_goma=false goma_dir="None" v8_enable_backtrace=true v8_enable_disassembler=true \
           v8_enable_object_print=true v8_enable_verify_heap=true' \
        && ninja -C $SOURCE_DIR/v8/out/s390x.release \
        && mkdir -p /v8 \
        && cp -R $SOURCE_DIR/v8/* /v8

FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

WORKDIR /v8

COPY --from=builder /v8/include /v8/include
COPY --from=builder /v8/out/s390x.release/d8 /v8/out/s390x.release/snapshot_blob.bin  /v8/out/s390x.release/v8_shell /v8/

CMD /v8/d8

# End of Dockerfile
