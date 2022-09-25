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

# reference
# https://gitlab.com/nvidia/container-images/samples/-/blob/main/deployments/container/Makefile
# https://gitlab.com/nvidia/container-images/samples/-/blob/main/deployments/container/Dockerfile.ubuntu
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

BASE_DIST=ubuntu20.04
CUDA_VERSION=11.4.1

#### DEVEL #############

echo " - ${bold}BUILD DEVEL${reset}"

BASE_IMAGE=isaac_ros/base:devel

docker build \
    -t isaac_ros/base:devel \
    --build-arg BASE_DIST="$BASE_DIST" \
    --build-arg CUDA_VERSION="$CUDA_VERSION" \
    -f Dockerfile.devel \
    .

docker build \
    -t isaac_ros/base:humble-devel \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -f Dockerfile.humble \
    .

#### RUNTIME #############

echo " - ${bold}BUILD RUNTIME${reset}"

BASE_IMAGE=isaac_ros/base:runtime

docker build \
    -t isaac_ros/base:runtime \
    --build-arg BASE_DIST="$BASE_DIST" \
    --build-arg CUDA_VERSION="$CUDA_VERSION" \
    -f Dockerfile.runtime \
    .

docker build \
    -t isaac_ros/base:humble \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -f Dockerfile.humble \
    .
