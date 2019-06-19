#!/usr/bin/env bash
. ./.config.sh

docker rm -f "${DEVENV_CONTAINER_NAME}" 2>/dev/null || true

docker run \
  --name "${DEVENV_CONTAINER_NAME}" \
  --volume /var/home/data/local:/var/home/data/local \
  --net host \
  --cap-add=SYS_PTRACE \
  --security-opt label=disable \
  --restart always \
  -d \
  "${DEVENV_IMAGE_NAME}"

docker ps

