FROM nvidia/cuda:13.1.1-base-ubuntu24.04@sha256:e8c8679ccd042249d4c4080a3fab5a6bb52ab6e771addffa2e6e4eafea797bd2
ARG WEBUI_VERSION=v1.10.1
ARG PYTHON_VERSION=3.10

ENV python_cmd=python${PYTHON_VERSION}
ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y software-properties-common fonts-dejavu-core rsync git jq moreutils aria2 libgoogle-perftools-dev \
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential && \
  # Yes, we do need 2 apt sets, as add-apt-repository comes from software-properties-common
  add-apt-repository ppa:deadsnakes/ppa -y && \
  apt-get install -y ${python_cmd} ${python_cmd}-venv && \
  git config --global --add safe.directory '*' && \
  apt-get clean && \
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

ENV venv_dir="venv"
ENV install_dir="/opt"
ENV clone_dir="webui"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""

# This isn't great. Unfortunately, `pip` doesn't use move and instead uses rename, which doesn't work across filesystems.
# This bites us when webui tries to install extensions, as they're first downloaded to /tmp, and then renamed to the extension dir. 
# This is a workaround, where we shove tmp into the same filesystem as the extension dir.
ENV TMPDIR="${ROOT}/extensions/tmp"

RUN /opt/webui/webui.sh --exit --skip-torch-cuda-test --xformers

EXPOSE 7860
ENTRYPOINT ["/opt/webui/webui.sh"]
CMD ["--listen", "--port", "7860", "--api", "--allow-code", "--medvram", "--xformers", "--enable-insecure-extension-access"]
