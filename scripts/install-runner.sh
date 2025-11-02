#!/bin/bash -e

VERSION="2.328.0"

mkdir -p "$RUNNER_HOME"
cd "$RUNNER_HOME" || exit

file="actions-runner-linux-x64-$VERSION.tar.gz"

curl -O -L https://github.com/falcondev-oss/github-actions-runner/releases/download/v$VERSION/$file
# Extract the installer
tar xzf $file && rm -f $file

# Prepare directory and env variable for toolcache
mkdir -p "$AGENT_TOOLSDIRECTORY"
echo "AGENT_TOOLSDIRECTORY=$AGENT_TOOLSDIRECTORY" >> .env
echo "RUNNER_TOOL_CACHE=$AGENT_TOOLSDIRECTORY" >> .env

chmod -R 777 "$AGENT_TOOLSDIRECTORY"
chmod -R 777 "$RUNNER_HOME"

echo "Runner env:" && cat .env
echo "Dir tree:" && tree -a -L 2