# Isaac ROS Base - Multi architecture & CI based

[![build](https://github.com/rbonghi/isaac_ros_base/actions/workflows/docker_build.yml/badge.svg)](https://github.com/rbonghi/isaac_ros_base/actions/workflows/docker_build.yml)

Multi architecture cross compilable Isaac ROS for x86 and NVIDIA Jetson with **Jetpack 5.0+**

> **Note**: Repository under construction

# Requirements

Desktop
* NVIDIA Graphic card

NVIDIA Jetson
* Xavier or Orin series
* Jetpack 5.0+

# Install

There are two ways to use this repository, build locally the isaac_ros_base images or use in CI, but you need to install a local runner on your desktop with NVIDIA graphic card

## Build locally

If you want to run locally use and follow the help:

> **Warning**: 
> You can use this script only on:
>  * x86 machines with NVIDIA graphic card
>  * NVIDIA Jetson Orin or Xavier series

```
./docker_build_ros.sh
```

## isaac_ros_runner

Follow README in [isaac_ros_runner](isaac_ros_runner) folder

## Images available

| Name                                | AMD64 | ARM64 |
|-------------------------------------|-------|-------|
| rbonghi/isaac_ros_base:devel        | Yes   | Yes   |
| rbonghi/isaac_ros_base:runtime      | Yes   | Yes   |
| rbonghi/isaac_ros_base:humble-devel | Yes   | Yes   |
| rbonghi/isaac_ros_base:humble       | Yes   | Yes   |

# Test build Isaac ROS

```
docker build -t isaac_ros/packages:latest -f Dockerfile.isaac .
```