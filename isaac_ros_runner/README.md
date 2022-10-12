# isaac_ros_runner

Github actions server runner based from [Docker Github Actions Runner](https://github.com/myoung34/docker-github-actions-runner)

# Before install

You need a [Github token PAT](https://developer.github.com/v3/actions/self_hosted_runners/#create-a-registration-token)

the following scopes are selected:

* repo (all)
* workflow
* admin:org (all) (**mandatory for organization-wide runner**)
* admin:public_key - read:public_key
* admin:repo_hook - read:repo_hook
* admin:org_hook
* notifications

# Install

Follow the installer running, from **`isaac_ros_runner`** folder:

```
bash installer.sh
```

This script do:
 1. Ask GitHub Action token and create `.env` file
 2. Check and Install `docker` and `docker-compose-plugin` (v2)
 3. Install `nvidia-docker2` (for desktop)
 4. Add permission to **docker** user
 5. Set default NVIDIA runtime
 6. restart docker service

> **Note**: You need to logout/login from your board/desktop!

# Run github action runner

from **`isaac_ros_runner`** folder:

```
docker compose  up -d
```

# Stop Github action runner

from **`isaac_ros_runner`** folder:

```
docker compose down
```