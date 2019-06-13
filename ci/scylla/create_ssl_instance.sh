#!/usr/bin/env bash
# Create a new scylla container with ssl support
# See: https://hub.docker.com/r/scylladb/scylla
# Also see: http://docs.scylladb.com/admin/#networking

# break after command error
set -e

# check arguments
NODE_NAME="$1"
DOCKER_PARAMETERS="$2"
SCYLLA_PARAMETERS="$3"
if [ -z "${NODE_NAME}" ]; then
	echo "Usage: $0 NODE_NAME [DOCKER_PARAMETERS] [SCYLLA_PARAMETERS]"
	echo "Example: $0 1 \"-p 7001,9042\" \"--seeds=192.168.18.131\""
	exit 1
fi

# define paths
KEYS_DIR="$HOME/.scylla/keys"
DATA_DIR="$HOME/.scylla/data-${NODE_NAME}"
SCRIPT_DIR="$(dirname $(realpath $0))"
CA_PEM_PATH="${KEYS_DIR}/ca.pem"
DB_KEY_PATH="${KEYS_DIR}/db-${NODE_NAME}.key"
DB_CRT_PATH="${KEYS_DIR}/db-${NODE_NAME}.crt"

# define parameters
CONTAINER_NAME="db-${NODE_NAME}"
HOST_NAME="${CONTAINER_NAME}"
NETWORK_NAME="database"
DUMMY_CONTAINER_NAME="db-dummy-only-for-ip"

# check key files
if [ ! -f "${CA_PEM_PATH}" ]; then
	echo "Error: file ${CA_PEM_PATH} not exists"
	exit 1
fi
if [ ! -f "${DB_KEY_PATH}" ] || [ ! -f "${DB_CRT_PATH}" ]; then
	echo "Error: file ${DB_KEY_PATH} or ${DB_CRT_PATH} not exists"
	exit 1
fi

# copy tree and key files
mkdir -p "${DATA_DIR}/data"
mkdir -p "${DATA_DIR}/commitlog"
rm -rfv "${DATA_DIR}/_tree"
cp -rfv "${SCRIPT_DIR}/files_for_ssl_instance" "${DATA_DIR}/_tree"
cp -fv "${CA_PEM_PATH}" "${DATA_DIR}/_tree/etc/scylla/ca.pem"
cp -fv "${DB_KEY_PATH}" "${DATA_DIR}/_tree/etc/scylla/db.key"
cp -fv "${DB_CRT_PATH}" "${DATA_DIR}/_tree/etc/scylla/db.crt"
mv -fv "${DATA_DIR}/_tree/entrypoint.sh" "${DATA_DIR}/"
sed -i "s/localhost/${HOST_NAME}/g" "${DATA_DIR}/_tree/root/.cassandra/cqlshrc"

# get available ip address from dummy container
docker rm -f "${DUMMY_CONTAINER_NAME}" &> /dev/null || true
docker run --name "${DUMMY_CONTAINER_NAME}" --net "${NETWORK_NAME}" -d scylladb/scylla
IP_ADDRESS=$(docker inspect --format="{{ .NetworkSettings.Networks.${NETWORK_NAME}.IPAddress }}" "${DUMMY_CONTAINER_NAME}")
docker rm -f "${DUMMY_CONTAINER_NAME}"  > /dev/null

# create scylla container
docker rm -f "${CONTAINER_NAME}"  &> /dev/null || true
docker run \
  --name "${CONTAINER_NAME}" \
  --hostname "${HOST_NAME}" \
  --net "${NETWORK_NAME}" \
  --ip "${IP_ADDRESS}" \
  --volume "${DATA_DIR}:/var/lib/scylla" \
  --security-opt label=disable \
  --restart always \
  --entrypoint "bash" \
  ${DOCKER_PARAMETERS} \
  -d scylladb/scylla \
  "/var/lib/scylla/entrypoint.sh" \
  ${SCYLLA_PARAMETERS}

echo
echo "<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"
echo "Scylla container with ssl support created"
echo "IP address: $IP_ADDRESS"
echo "View logs: docker logs ${CONTAINER_NAME} | tail"
echo "Enter container: docker exec -it ${CONTAINER_NAME} bash"
echo "Remove container: docker rm -f ${CONTAINER_NAME}"
echo "Run cqlsh: docker exec -it ${CONTAINER_NAME} cqlsh --ssl"
echo "<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"

