#!/usr/bin/env bash

openssl aes-256-cbc -k "$CONSTANTS_KEY" -in Vendor/VEConstants.h.enc -d -a -out Various/VEConstants.h
