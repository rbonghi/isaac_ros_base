# Isaac ROS Base - Docker CI

Multiplatform cross compilable Isaac ROS for Jetson and x86

> **Note**: Repository under construction

# Install

There are two ways to use this repository, build locally the isaac_ros_base images or use in CI, but you need to install a local runner on your desktop with NVIDIA graphic card

## Build locally

If you want to run locally use and follow the help:

```
./build_ros.sh
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