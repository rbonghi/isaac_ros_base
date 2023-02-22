# Isaac ROS Base - Multi architecture & CI based

[![Docker Pulls](https://img.shields.io/docker/pulls/rbonghi/isaac-ros-base)](https://hub.docker.com/r/rbonghi/isaac-ros-base) ![GitHub](https://img.shields.io/github/license/rbonghi/isaac_ros_base)

Multi architecture cross compilable Isaac ROS for x86 and NVIDIA Jetson with **Jetpack 5+**

## Requirements

To build these NVIDIA Docker you can choose one of these options:

1. **Desktop**
   * NVIDIA Graphic card
2. **NVIDIA Jetson**
   * Xavier or Orin series
   * NVIDIA Jetpack 5+

## Images available

All images are based with:

| Software | Version JP=5.0.2 | Version JP=5.1   |
|----------|:----------------:|:----------------:|
| Ubuntu   | 20.04            | 20.04            |
| L4T      | 35.1             | 35.2             |
| CUDA     | 11.4             | 11.4             |
| OpenCV   | 4.5.0 with CUDA  | 4.5.0 with CUDA  |
| TensorRT | 8.4              | 8.4              |
| Triton   | 2.24.0           | 2.30.0           |

Images:

| Name                                  | AMD64 | ARM64 | Note | Build Time |
|---------------------------------------|:-----:|:-----:|------|------|
| `rbonghi/isaac_ros_base:humble-core-devel` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/humble-core-devel?arch=amd64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/humble-core-devel?arch=arm64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | Minimal packages **ros-core** and all main package for vision compiled with CUDA | 16000s (L4T 35.1)<br/>15000s (L4T 35.2) |
| `rbonghi/isaac_ros_base:humble-base-devel` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/humble-base-devel?arch=amd64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/humble-base-devel?arch=arm64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) |  | 16000s (L4T 35.1)<br/>Xs (L4T 35.2) |
| `rbonghi/isaac_ros_base:gems-devel` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/gems-devel?arch=amd64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/gems-devel?arch=arm64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | *Isaac ROS argus camera* is available **only** on ARM64 platform |
| `rbonghi/isaac_ros_base:isaac-runtime`       | Soon   | Soon   |  |

## Work with Isaac ROS base

Example to build Isaac ROS packages multi-platform

```bash
cd example
docker build -t isaac-ros-base/packages:latest -f Dockerfile.isaac .
```

## Build

There are two ways to use this repository, build locally the isaac_ros_base images or use in CI, but you need to install a local runner on your desktop with NVIDIA graphic card.

### Setup Docker runtime on Jetson

To enable access to the CUDA compiler (nvcc) during docker build operations, add `"default-runtime"`: `"nvidia"` to your `/etc/docker/daemon.json` configuration file before attempting to build the containers:

```json
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
```

You will then want to restart the Docker service or reboot your system before proceeding.

```bash
sudo systemctl restart docker.service
```

Add your user on your docker group

```bash
sudo usermod -aG docker $USER
```

*Logout* and login on your session.

### Build locally

If you want to run locally use and follow the help:

> **Warning**:
> You can use this script only on:
>
> * x86 machines with NVIDIA graphic card
> * NVIDIA Jetson Orin or Xavier series

```bash
./docker_build_ros.sh
```

### isaac_ros_runner

Follow README in [isaac_ros_runner](isaac_ros_runner) folder

### Multistage images

| Name                                  | AMD64 | ARM64 | Build Time |
|---------------------------------------|:-----:|:-----:|------------|
| `rbonghi/isaac_ros_base:opencv-4.5.0`        | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/opencv-4.5.0?arch=amd64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/opencv-4.5.0?arch=arm64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | |
| `rbonghi/isaac_ros_base:devel`        | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/devel?arch=amd64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rbonghi/isaac-ros-base/devel?arch=arm64)](https://hub.docker.com/r/rbonghi/isaac-ros-base) |  2000s (L4T 35.1)<br/>2500s (L4T 35.2) |
| `rbonghi/isaac_ros_base:runtime`      | Soon   | Soon   | |
