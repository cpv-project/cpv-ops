#!/usr/bin/env bash
. ./.config.sh
docker build -t "${DEVENV_IMAGE_NAME}" ../docker/devenv --no-cache=true
docker system prune -f

