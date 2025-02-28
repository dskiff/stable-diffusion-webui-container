# stable-diffusion-webui-container

Run [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a container.

## How?

You'll need a way to run containers (e.g. Docker, podman, k8s, etc), and you'll need to be able to pass your GPU to the container (e.g. the [NVIDIA  Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))

Checkout the docker-compose as a simple example, or

```
docker run -p=7860:7860 --gpus=all ghcr.io/dskiff/stable-diffusion-webui-container:latest
```