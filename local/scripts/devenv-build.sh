#!/usr/bin/env bash
. ./.config.sh
docker build -t "${DEVENV_IMAGE_NAME}" ../docker/devenv
docker system prune -f

