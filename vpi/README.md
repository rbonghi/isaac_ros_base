# Testing VPI

This test docker is made to check the VPI capabilities for a NVIDIA Jetpack


## Jetpack 5.0.2

Build

```bash
docker build --build-arg L4T=35.1 -t rbonghi/isaac_ros_base:vpi-test -f Dockerfile.vpi .
```

Should crash!

```bash
docker build --build-arg L4T=35.1 --build-arg SKIP_MAKE=yes -t rbonghi/isaac_ros_base:vpi-test-run -f Dockerfile.vpi  .
```

## Jetpack 5.1

```bash
docker build --build-arg L4T=35.2 -t rbonghi/isaac_ros_base:vpi-test -f Dockerfile.vpi .
```

## Test with buildx

```bash
docker buildx build --build-arg L4T=35.2 -t rbonghi/isaac_ros_base:vpi-test --platform linux/arm64,linux/amd64 --push -f Dockerfile.vpi .
```
