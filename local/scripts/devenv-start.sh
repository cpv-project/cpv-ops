#!/usr/bin/env bash
. ./.config.sh

docker rm -f "${DEVENV_CONTAINER_NAME}" 2>/dev/null || true
docker system prune -f

docker run \
  --name "${DEVENV_CONTAINER_NAME}" \
  --volume /var/home/data/local:/var/home/data/local \
  --net host \
  --cap-add=SYS_PTRACE \
  --cap-add=SYS_NICE \
  --cap-add=SYS_ADMIN \
  --cap-add=SYSLOG \
  --security-opt label=disable \
  --restart always \
  -p 8000:8000 \
  -d \
  "${DEVENV_IMAGE_NAME}"

docker ps

