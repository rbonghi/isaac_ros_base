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

# Idea from
# 1. https://github.com/Qengineering/Install-OpenCV-Jetson-Nano/blob/main/OpenCV-4-5-0.sh
# 2. https://gist.github.com/raulqf/f42c718a658cddc16f9df07ecc627be7

set -e -x

OPENCV_VERSION=${1:-4.5.0}

NUM_CPU=$(nproc)

OPENCV_FOLDER="/opt/opencv"
ENABLE_NONFREE=ON

ARCH=$(uname -i)
echo "ARCH:  $ARCH"

echo "Installing OpenCV ${OPENCV_VERSION} on $ARCH"

# Install OpenCV dependencies
apt-get update
apt-get install -y \
    libavformat-dev \
    libjpeg-dev \
    libopenjp2-7-dev \
    libpng-dev \
    libpq-dev \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libtiff-dev \
    pkg-config \
    yasm

# Move to opt folder
cd /opt
# download OpenCV version source code
wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip 
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip 
# unpack
unzip opencv.zip 
unzip opencv_contrib.zip 
# some administration to make live easier later on
mv opencv-${OPENCV_VERSION} opencv
mv opencv_contrib-${OPENCV_VERSION} ${OPENCV_FOLDER}/opencv_contrib
# clean up the zip files
rm opencv.zip
rm opencv_contrib.zip

# set install dir
cd $OPENCV_FOLDER
mkdir build
cd build

# https://developer.nvidia.com/cuda-gpus
# https://forums.developer.nvidia.com/t/what-is-the-compute-capability-for-the-orion-update-your-page/211447
if [ "$(uname -m)" = "x86_64" ]; then
    CUDA_ARCH_BIN=7.5
    ENABLE_NEON=OFF
else
    # NVIDIA Jetson Xavier series = 7.2
    # NVIDIA Jetson Orin series = 8.7
    CUDA_ARCH_BIN=7.2,8.7
    ENABLE_NEON=ON
fi

echo "cmake openCV with CUDA_ARCH_BIN=$CUDA_ARCH_BIN"

# run cmake
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr \
-D OPENCV_EXTRA_MODULES_PATH=${OPENCV_FOLDER}/opencv_contrib/modules \
-D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
-D WITH_OPENCL=OFF \
-D WITH_CUDA=ON \
-D CUDA_ARCH_BIN=$CUDA_ARCH_BIN \
-D CUDA_ARCH_PTX="" \
-D WITH_CUDNN=ON \
-D WITH_CUBLAS=ON \
-D ENABLE_FAST_MATH=ON \
-D CUDA_FAST_MATH=ON \
-D OPENCV_DNN_CUDA=ON \
-D ENABLE_NEON=$ENABLE_NEON \
-D WITH_QT=OFF \
-D WITH_OPENMP=ON \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_GSTREAMER=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=ON \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D OPENCV_ENABLE_NONFREE=$ENABLE_NONFREE \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_NEW_PYTHON_SUPPORT=ON \
-D BUILD_opencv_python3=TRUE \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF ..

echo "Make openCV with $NUM_CPU CPU"
make -j$(($NUM_CPU - 1))

rm -r /usr/include/opencv4/opencv2
make install
ldconfig

echo "Clean OpenCV installation"

# cleaning (frees 300 MB)
make clean
rm -rf /var/lib/apt/lists/*
apt-get clean
# Remove OpenCV folder
rm -R $OPENCV_FOLDER

echo "Installed OpenCV ${OPENCV_VERSION} on $ARCH"

# test importing cv2
echo "testing cv2 module under python..."
python3 -c "import cv2; print('OpenCV version:', str(cv2.__version__)); print(cv2.getBuildInformation())"