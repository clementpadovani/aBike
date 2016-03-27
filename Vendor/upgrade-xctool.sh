#!/usr/bin/env bash

set -e

XCODEBUILD_VERSION=$(xcodebuild -version)
XCODEBUILD_VERSION=`expr "$XCODEBUILD_VERSION" : '^.*Build version \(.*\)'`

if [ $XCODEBUILD_VERSION == "7D175" ]
then
	echo "Is Xcode 7.3"
	brew update
	brew uninstall xctool && brew install --HEAD xctool
else
	echo "Isn't Xcode 7.3"
fi