#!/bin/bash
# © Copyright IBM Corporation 2024, 2026
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
set -o errexit -o nounset -o pipefail

apt-get update

export DEBIAN_FRONTEND="noninteractive"
export TZ="Etc/UTC"

apt-get install --yes \
    build-essential \
    curl \
    git \
    openjdk-8-jdk \
    python3 \
    python3-pip \
    unzip \
    zip \
    sudo

ln -s "$(which python3)" /usr/bin/python
