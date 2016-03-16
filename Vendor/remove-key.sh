#!/usr/bin/env bash

set -e

security delete-keychain ios-build.keychain
rm -f "~/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
