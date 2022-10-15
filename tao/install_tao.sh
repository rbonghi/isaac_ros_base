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


#COPY tao/tao-converter-aarch64-tensorrt${TENSORRT_VERSION}.zip /opt/nvidia/tao/tao-converter-aarch64-tensorrt${TENSORRT_VERSION}.zip
#wget --content-disposition https://api.ngc.nvidia.com/v2/resources/nvidia/tao/tao-converter/versions/v3.21.11_trt7.1_agx/zip -O tao-converter_v3.21.11_trt7.1_agx.zip

set -e -x

TENSORRT_VERSION=$1

# Build NVIDIA TAO folder
mkdir -p /opt/nvidia/tao
cd /opt/nvidia/tao

if [ "$(uname -m)" = "x86_64" ]; then 
    wget https://developer.nvidia.com/tao-converter-80
    unzip tao-converter-80
    chmod 755 $(find /opt/nvidia/tao -name "tao-converter")
    ln -sf $(find /opt/nvidia/tao -name "tao-converter") /opt/nvidia/tao/tao-converter
    # Clean sources
    rm tao-converter-80 tao-converter-aarch64-tensorrt${TENSORRT_VERSION}.zip
else
    unzip -j tao-converter-aarch64-tensorrt${TENSORRT_VERSION}.zip -d /opt/nvidia/tao/jp5
    chmod 755 $(find /opt/nvidia/tao -name "tao-converter")
    ln -sf $(find /opt/nvidia/tao -name "tao-converter")  /opt/nvidia/tao/tao-converter
    # Clean sources
    rm tao-converter-aarch64-tensorrt${TENSORRT_VERSION}.zip
fi