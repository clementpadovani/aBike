#!/usr/bin/env bash

set -e

brew update
brew outdated xctool || brew upgrade xctool
