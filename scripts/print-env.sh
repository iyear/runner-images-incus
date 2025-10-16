#!/bin/bash -e

echo "=== /etc/environment ==="
cat /etc/environment

echo "=== Environment Variables ==="
env | sort