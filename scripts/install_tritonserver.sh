#!/bin/bash
# Copyright (c) 2022, NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

set -e -x

TRITON_VERSION=$1
JETPACK=$2

# Install Triton server 2.24 from https://github.com/triton-inference-server/server/releases/tag/v2.24.0

# Install all Triton Server dependencies
apt-get update
apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    libb64-dev \
    libcurl4-openssl-dev \
    libopenblas-dev \
    libre2-dev \
    libssl-dev \
    libtool \
    patchelf \
    rapidjson-dev \
    zlib1g-dev

# Build triton server folder
mkdir -p /opt/tritonserver
cd /opt/tritonserver

# Install Triton for NVIDIA Jetson or X86_64 architecture
if [ "$(uname -m)" = "x86_64" ]; then
    wget https://github.com/triton-inference-server/server/releases/download/v${TRITON_VERSION}/v${TRITON_VERSION}_ubuntu2004.clients.tar.gz
    tar -xzvf v${TRITON_VERSION}_ubuntu2004.clients.tar.gz
    rm v${TRITON_VERSION}_ubuntu2004.clients.tar.gz
else
    wget https://github.com/triton-inference-server/server/releases/download/v${TRITON_VERSION}/tritonserver${TRITON_VERSION}-jetpack${JETPACK}.tgz
    tar -xzvf tritonserver${TRITON_VERSION}-jetpack${JETPACK}.tgz
    rm tritonserver${TRITON_VERSION}-jetpack${JETPACK}.tgz
fi

# Clean apt-get cache
rm -rf /var/lib/apt/lists/*
apt-get clean