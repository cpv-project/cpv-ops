#!/usr/bin/env bash
# Generate private and public key for a single node, should run for every node.
# See: http://docs.scylladb.com/tls-ssl

# break after command error
set -e

KEYS_DIR="$HOME/.scylla/keys"
CA_KEY_NAME="ca.key"
CA_PEM_NAME="ca.pem"
CA_SRL_NAME="ca.srl"
NODE_NAME="$1"
KEY_NAME="db-${NODE_NAME}.key"
CSR_NAME="db-${NODE_NAME}.csr"
CFG_NAME="db-${NODE_NAME}.cfg"
CRT_NAME="db-${NODE_NAME}.crt"

if [ -z "${NODE_NAME}" ]; then
	echo "Usage: $0 NODE_NAME"
	exit 1
fi

mkdir -p "${KEYS_DIR}"
cd "${KEYS_DIR}"

if [ ! -f "${CA_KEY_NAME}" ]; then
	echo "Error: please put ${CA_KEY_NAME} in ${KEYS_DIR}"
	exit 1
fi
if [ ! -f "${CA_PEM_NAME}" ]; then
	echo "Error: please put ${CA_PEM_NAME} in ${KEYS_DIR}"
	exit 1
fi

if [ -f "${KEY_NAME}" ]; then
	echo "Error: ${KEY_NAME} already exists"
	exit 1
fi
if [ -f "${CRT_NAME}" ]; then
	echo "Error: ${CRT_NAME} already exists"
	exit 1
fi

cat > "${CFG_NAME}" << EOL
[ req ]
default_bits = 4096
default_keyfile = ${KEY_NAME}
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
[ req_distinguished_name ]
O = cpv-internal
OU = cpv-internal
CN = db-${NODE_NAME}.cpv-internal
emailAddress = root@cpv-internal
[v3_ca]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:true
[v3_req]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
EOL

openssl genrsa -out "${KEY_NAME}" 4096
openssl req -new -key "${KEY_NAME}" -out "${CSR_NAME}" -config "${CFG_NAME}"
openssl x509 -req -in "${CSR_NAME}" -CA "${CA_PEM_NAME}" -CAkey "${CA_KEY_NAME}" -CAcreateserial -out "${CRT_NAME}" -days 36500
rm -fv "${CSR_NAME}" "${CFG_NAME}" "${CA_SRL_NAME}"

