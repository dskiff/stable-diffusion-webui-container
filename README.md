# stable-diffusion-webui-container

Run [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a container.

## How?

Checkout the docker-compose as a simple example, or

```
docker run -p=7860:7860 --gpus=all ghcr.io/dskiff/stable-diffusion-webui-container:latest
```