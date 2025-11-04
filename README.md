A repository for building a working environment for ARM based projects development.

Component versions:

- arm-none-eabi: 0.16.8
- openocd: 0.12.0
- clangd: 21.1.0

Before build container, tag base image as local because of network issue
```
docker tag ubuntu:24.04 ubuntu-local:24.04
```

Frequent commands when building an image
```
docker container list
docker build -t arm-devcontainer .
docker run -it arm-devcontainer
docker image rm arm-devcontainer --force
```

