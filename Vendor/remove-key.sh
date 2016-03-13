#!/usr/bin/env sh

security delete-keychain ios-build.keychain
rm -f -v "~/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"

echo "Deleted provisioning profile"
