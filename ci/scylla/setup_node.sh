#!/usr/bin/env bash
# setup docker environment in a single node, should run for every nodes
# break after command error
set -e

# pull scylla image
# See: https://hub.docker.com/r/scylladb/scylla
docker pull scylladb/scylla
docker images

# create internode network
docker network create --subnet=172.88.0.0/16 database || true
docker network ls

