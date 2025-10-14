#!/usr/bin/env bash

# From runner-images/scripts/install-git.sh

GIT_REPO="ppa:git-core/ppa"

## Install git
add-apt-repository $GIT_REPO -y
apt-get update
apt-get install git

# Git version 2.35.2 introduces security fix that breaks action\checkout https://github.com/actions/checkout/issues/760
cat <<EOF >> /etc/gitconfig
[safe]
        directory = *
EOF

# Install git-ftp
apt-get install git-ftp

# Remove source repo's
add-apt-repository --remove $GIT_REPO

# Add well-known SSH host keys to known_hosts
ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /etc/ssh/ssh_known_hosts