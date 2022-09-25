
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

BASE_IMAGE=nanosaur/base:devel

docker build \
    -t nanosaur/base:devel \
    --build-arg BASE_DIST="$BASE_DIST" \
    --build-arg CUDA_VERSION="$CUDA_VERSION" \
    -f Dockerfile.devel \
    .

docker build \
    -t nanosaur/base:humble-devel \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -f Dockerfile.humble \
    .

#### RUNTIME #############

echo " - ${bold}BUILD RUNTIME${reset}"

BASE_IMAGE=nanosaur/base:runtime

docker build \
    -t nanosaur/base:runtime \
    --build-arg BASE_DIST="$BASE_DIST" \
    --build-arg CUDA_VERSION="$CUDA_VERSION" \
    -f Dockerfile.runtime \
    .

docker build \
    -t nanosaur/base:humble \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -f Dockerfile.humble \
    .
