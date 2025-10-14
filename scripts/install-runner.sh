#!/usr/bin/env bash

VERSION="2.320.0"

mkdir -p /home/runner/actions-runner
cd /home/runner/actions-runner || exit

curl -O -L https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-$VERSION.tar.gz
# Extract the installer
tar xzf ./actions-runner-linux-x64-$VERSION.tar.gz