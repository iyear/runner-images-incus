#!/bin/bash -e

VERSION="2.320.0"

mkdir -p /home/runner/actions-runner
cd /home/runner/actions-runner || exit

file="actions-runner-linux-x64-$VERSION.tar.gz"

curl -O -L https://github.com/actions/runner/releases/download/v2.320.0/$file
# Extract the installer
tar xzf $file && rm -f $file