# Testing VPI

This test docker is made to check the VPI capabilities for a NVIDIA Jetpack


## Jetpack 5.0.2

Build

```bash
docker build --build-arg L4T=35.1 -t vpi-test -f Dockerfile.vpi .
```

Should crash!

```bash
docker build --build-arg L4T=35.1 --build-arg SKIP_MAKE=yes -t vpi-test-run -f Dockerfile.vpi  .
```

## Jetpack 5.1

```bash
docker build --build-arg L4T=35.2 -t vpi-test -f Dockerfile.vpi .
```
