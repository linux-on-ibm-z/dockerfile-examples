#!/bin/bash
# © Copyright IBM Corporation 2024
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#

set -o errexit -o nounset -o pipefail

apt-get update

export DEBIAN_FRONTEND="noninteractive"
export TZ="Etc/UTC"

apt-get install --yes \
    build-essential \
    curl \
    sudo \
    git \
    openjdk-11-jdk-headless \
    openjdk-21-jdk-headless \
    python3 \
    python3-pip \
    python-is-python3 \
    unzip \
    zip
