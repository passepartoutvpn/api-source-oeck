#!/bin/bash
URL="https://www.oeck.com/oeck-servers.json"
TPL="template"
SERVERS="$TPL/servers.json"

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L $URL >$SERVERS; then
    exit
fi
