# Isaac ROS Base - Docker CI

Multiplatform cross compilable Isaac ROS for Jetson and x86

> **Note**: Repository under construction

# Build

Run

```
./build_ros.sh
```

# Images

| Name                        | x86 | ARM64 |
|-----------------------------|-----|-------|
| isaac_ros/base:devel        | Yes | Yes   |
| isaac_ros/base:humble-devel | Yes | Yes   |
| isaac_ros/base:runtime      | Yes | Yes   |
| isaac_ros/base:humble       | Yes | Yes   |

# Test build Isaac ROS

```
docker build -t isaac_ros/packages:latest -f Dockerfile.isaac .
```