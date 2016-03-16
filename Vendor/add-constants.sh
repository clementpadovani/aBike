#!/usr/bin/env bash

set -e

openssl aes-256-cbc -k "$CONSTANTS_KEY" -in Vendor/VEConstants.h.enc -d -a -out Various/VEConstants.h

if [ -f "./Various/VEConstants.h" ]; then

	exit 0

else

	echo "Failed to copy VEConstants.h"

	exit 1

fi
