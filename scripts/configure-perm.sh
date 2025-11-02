#!/bin/bash -e

# for range PERM_PATHS separated by space, set permission to 777, no default value
if [ -n "${PERM_PATHS:-}" ]; then
  for path in $PERM_PATHS; do
    echo "Setting permission 777 for path: $path"
    chmod -R 777 "$path"
  done
else
  echo "No PERM_PATHS provided, skipping permission configuration."
fi