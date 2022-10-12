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

BUILD_BASE=devel

usage()
{
    if [ "$1" != "" ]; then
        echo "${red}$1${reset}" >&2
    fi

    local name=$(basename ${0})
    echo "$name isaac_ros_base for different architectures." >&2
    echo "${bold}Commands:${reset}" >&2
    echo "  $name help                     This help" >&2
    echo "  $name devel [OPTIONS ...]      Build devel image" >&2
    echo "  $name runtime [OPTIONS ...]    Build runtime image" >&2
    echo "  $name humble [OPTIONS ...]     Build ROS2 humble image" >&2
    echo
    echo "${bold}OPTIONS:${reset}"
    echo " --buildx                        Use docker buildx" >&2
    echo " --ci                            Run build in CI (without cash and pull a latest base image)" >&2
    echo " --base [NAME]                   Build from base image. Default: ${bold}$BUILD_BASE${reset}" >&2
    echo " --multiarch                     Build in multiarch (ARM64 and AMD64)" >&2
    echo " --arm64                         Build for arm64 architecture" >&2
    echo " --amd64                         Build for x86_64 architecture" >&2
}


main()
{
    local BUILD_MULTI_ARCH_IMAGES=false
    local BUILDX=""
    local ARCH=""
    local MULTIARCH=false
    local CI=false

    local docker_image_name=rbonghi/isaac-ros-base
    local BASE_DIST=ubuntu20.04
    local CUDA_VERSION=11.4.1
    # Check if run in sudo
    if [[ `id -u` -eq 0 ]] ; then 
        echo "${red}Please don't run as root${reset}" >&2
        exit 1
    fi
    local option=$1
    if [ -z "$option" ] ; then
        usage
        exit 0
    fi
    # Load all arguments except the first one
    while [ -n "$2" ]; do
        case "$2" in
            --buildx) # Load help
                BUILDX=buildx
                ;;
            --ci)
                CI=true
                ;;
            --arm64)
                ARCH="arm64"
                ;;
            --amd64)
                ARCH="amd64"
                ;;
            --base)
                BUILD_BASE=$3
                shift 1
                ;;
            --multiarch)
                MULTIARCH=true
                ;;
            *)
                usage "[ERROR] Unknown option: $2" >&2
                exit 1
                ;;
        esac
            shift 1
    done

    local multiarch_option=""
    if [ ! -z $BUILDX ] ; then
        # Check platform
        if [ "$ARCH" == "arm64" ] ; then
            multiarch_option="--platform linux/arm64"
        elif [ "$ARCH" == "amd64" ] ; then
            multiarch_option="--platform linux/amd64"
        fi
        # Check if multiarch
        if $MULTIARCH ; then
            multiarch_option="--platform linux/arm64,linux/amd64"
        fi
    fi

    # Options
    if [ $option = "help" ] || [ $option = "-h" ]; then
        usage
        exit 0
    elif [ $option = "devel" ] ; then

        #### DEVEL #############
        echo " - ${bold}BUILD DEVEL${reset} - BASE_DIST=${green}$BASE_DIST${reset} CUDA_VERSION=${green}$CUDA_VERSION${reset}"

        docker ${BUILDX} build \
            -t $docker_image_name:devel \
            --build-arg BASE_DIST="$BASE_DIST" \
            --build-arg CUDA_VERSION="$CUDA_VERSION" \
            $multiarch_option \
            -f Dockerfile.devel \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }
        
        exit 0
    elif [ $option = "runtime" ] ; then
        #### RUNTIME #############
        echo " - ${bold}BUILD RUNTIME${reset} - BASE_DIST=${green}$BASE_DIST${reset} CUDA_VERSION=${green}$CUDA_VERSION${reset}"

        docker ${BUILDX} build \
            -t $docker_image_name:runtime \
            --build-arg BASE_DIST="$BASE_DIST" \
            --build-arg CUDA_VERSION="$CUDA_VERSION" \
            $multiarch_option \
            -f Dockerfile.runtime \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }

        exit 0
    elif [ $option = "humble" ] ; then
        BASE_IMAGE=$docker_image_name:$BUILD_BASE

        #### HUMBLE #############
        echo " - ${bold}BUILD HUMBLE${reset} - BASE_IMAGE=${green}$BASE_IMAGE${reset}"

        docker ${BUILDX} build \
            -t $docker_image_name:humble \
            --build-arg BASE_IMAGE="$BASE_IMAGE" \
            $multiarch_option \
            -f Dockerfile.humble-$BUILD_BASE \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }

        exit 0
    fi

    usage "[ERROR] Unknown option: $option" >&2
    exit 1
}
main $@
exit 0
# EOF
