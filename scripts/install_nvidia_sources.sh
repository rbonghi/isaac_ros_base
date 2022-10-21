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

L4T=$1

echo "Adding NVIDIA sources"

apt-get update
apt-get install -y software-properties-common
apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc

if [ "$(uname -m)" = "x86_64" ]; then
    # Adding sources for discrete NVIDIA GPU
    add-apt-repository "deb http://repo.download.nvidia.com/jetson/x86_64/focal r${L4T} main"
else
    # Adding sources for NVIDIA Jetson
    add-apt-repository "deb https://repo.download.nvidia.com/jetson/common r${L4T} main"
    # Workaround to source libraries on Docker
    echo "Installing sources jetson-multimedia-api"
    # Manually install jetson-multimedia-api sources
    apt-get download nvidia-l4t-jetson-multimedia-api
    # Package output like: nvidia-l4t-jetson-multimedia-api_35.1.0-20220825113828_arm64.deb
    dpkg -x nvidia-l4t-jetson-multimedia-api_*.deb /
    # Remove package
    rm nvidia-l4t-jetson-multimedia-api_*.deb
fi

# Clean sources
rm -rf /var/lib/apt/lists/*
apt-get clean