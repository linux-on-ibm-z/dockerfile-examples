#!/bin/bash

set -o errexit -o nounset -o pipefail

apt-get update

export DEBIAN_FRONTEND="noninteractive"
export TZ="Etc/UTC"

apt-get install --yes \
    build-essential \
    curl \
    git \
    openjdk-11-jdk-headless \
    python3 \
    python3-pip \
    python-is-python3 \
    unzip \
    zip
