FROM nvidia/cuda:12.8.0-base-ubuntu24.04@sha256:e778509d37d66475120929671500377524f7278478ba08131b07ef3ffcc0dce0
ARG WEBUI_VERSION=v1.10.1

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  apt-get upgrade -y && \
  # we need those
  apt-get install -y software-properties-common fonts-dejavu-core rsync git jq moreutils aria2 libgoogle-perftools-dev \
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential && \
  # Yes, we do need 2 apt sets, as add-apt-repository comes from software-properties-common
  add-apt-repository ppa:deadsnakes/ppa -y && \
  apt-get install -y python3.10 python3.10-venv && \
  git config --global --add safe.directory '*' && \
  rm -rf /var/lib/apt/lists/*

ENV ROOT=/opt/webui

WORKDIR ${ROOT}

RUN mkdir -p ${ROOT} && chown -R ubuntu:ubuntu ${ROOT}

# Prevent pip cacheing to mitigate some layer bloat
COPY pip.conf /etc/pip.conf

USER ubuntu

ENV PATH=/home/ubuntu/.local/bin:$PATH

RUN git init && \
  git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
  git fetch origin "${WEBUI_VERSION}" --depth=1 && \
  git reset --hard FETCH_HEAD

# see: https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions/6722
ENV LD_PRELOAD=libtcmalloc.so

ENV python_cmd=python3.10
ENV venv_dir="venv"
ENV install_dir="/opt"
ENV clone_dir="webui"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""

RUN /opt/webui/webui.sh --exit --skip-torch-cuda-test --xformers

EXPOSE 7860
ENTRYPOINT ["/opt/webui/webui.sh"]
CMD ["--listen", "--port", "7860", "--api", "--allow-code", "--medvram", "--xformers", "--enable-insecure-extension-access"]
