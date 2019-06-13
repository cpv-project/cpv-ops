#!/usr/bin/env bash
# Custom scylla container entry point
# This script may run multiple times if restart option is given

# update configs
cp -rfv /var/lib/scylla/_tree/* /

# disable incorrect cqlshrc update
sed -i "s/setup.cqlshrc/#_etup.cqlshrc/g" /docker-entrypoint.py

# run original entry point
python /docker-entrypoint.py $@

