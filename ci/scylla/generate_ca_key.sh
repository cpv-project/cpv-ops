#!/usr/bin/env bash
# Generate private and public key for certificate signing authority, should run just once.
# See: http://docs.scylladb.com/tls-ssl

# break after command error
set -e

KEYS_DIR="$HOME/.scylla/keys"
KEY_NAME="ca.key"
CFG_NAME="ca.cfg"
PEM_NAME="ca.pem"

mkdir -p "${KEYS_DIR}"
cd "${KEYS_DIR}"

if [ -f "${KEY_NAME}" ]; then
	echo "Error: ${KEY_NAME} already exists"
	exit 1
fi
if [ -f "${PEM_NAME}" ]; then
	echo "Error: ${PEM_NAME} already exists"
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
CN = ca.cpv-internal
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
openssl req -x509 -new -nodes -key "${KEY_NAME}" -days 36500 -config "${CFG_NAME}" -out "${PEM_NAME}"
rm -fv "${CFG_NAME}"

