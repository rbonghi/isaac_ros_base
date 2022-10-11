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


usage()
{
    if [ "$1" != "" ]; then
        echo "${red}$1${reset}" >&2
    fi

    local name=$(basename ${0})
    echo "$name Edge impulse on nanosaur." >&2
    echo "${bold}Commands:${reset}" >&2
    echo "  $name help                     This help" >&2
    echo "  $name devel                    Buld devel image" >&2
    echo "  $name runtime                  Build runtime image" >&2
}


main()
{
    local BUILD_MULTI_ARCH_IMAGES=false
    local BUILDX=""
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
    local arguments=${@:2}

    while [ -n "$2" ]; do
        case "$2" in
            --buildx) # Load help
                BUILDX=buildx
                ;;
            *)
                usage "[ERROR] Unknown option: $2" >&2
                exit 1
                ;;
        esac
            shift 1
    done

    # Options
    if [ $option = "help" ] || [ $option = "-h" ]; then
        usage
        exit 0
    elif [ $option = "devel" ] ; then
        #### DEVEL #############
        echo " - ${bold}BUILD DEVEL${reset}"

        BASE_IMAGE=isaac_ros/base:devel

        docker ${BUILDX} build \
            -t isaac_ros/base:devel \
            --build-arg BASE_DIST="$BASE_DIST" \
            --build-arg CUDA_VERSION="$CUDA_VERSION" \
            -f Dockerfile.devel \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }

        docker ${BUILDX} build \
            -t isaac_ros/base:humble-devel \
            --build-arg BASE_IMAGE="$BASE_IMAGE" \
            -f Dockerfile.humble \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }
        
        exit 0
    elif [ $option = "runtime" ] ; then
        #### RUNTIME #############
        echo " - ${bold}BUILD RUNTIME${reset}"

        BASE_IMAGE=isaac_ros/base:runtime

        docker ${BUILDX} build \
            -t isaac_ros/base:runtime \
            --build-arg BASE_DIST="$BASE_DIST" \
            --build-arg CUDA_VERSION="$CUDA_VERSION" \
            -f Dockerfile.runtime \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }

        docker ${BUILDX} build \
            -t isaac_ros/base:humble \
            --build-arg BASE_IMAGE="$BASE_IMAGE" \
            -f Dockerfile.humble \
            . || { echo "${red}docker build failure!${reset}"; exit 1; }

        exit 0
    fi

    usage "[ERROR] Unknown option: $option" >&2
    exit 1
}
main $@
exit 0
# EOF
