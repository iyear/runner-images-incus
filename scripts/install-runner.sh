#!/bin/bash -e

VERSION="2.320.0"

mkdir -p "$RUNNER_HOME"
cd "$RUNNER_HOME" || exit

file="actions-runner-linux-x64-$VERSION.tar.gz"

curl -O -L https://github.com/actions/runner/releases/download/v2.320.0/$file
# Extract the installer
tar xzf $file && rm -f $file

# Prepare directory and env variable for toolcache
mkdir -p "$AGENT_TOOLSDIRECTORY"
echo "AGENT_TOOLSDIRECTORY=$AGENT_TOOLSDIRECTORY" >> .env
echo "RUNNER_TOOL_CACHE=$AGENT_TOOLSDIRECTORY" >> .env
chmod -R 777 "$AGENT_TOOLSDIRECTORY"

echo "Runner env:" && cat .env
echo "Dir tree:" && tree -a -L 2