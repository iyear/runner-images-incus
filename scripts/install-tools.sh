#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  apt-utils \
  ca-certificates \
  apt-transport-https \
  software-properties-common \
  tree \
  dpkg \
  python3-launchpadlib \
  curl \
  tzdata \
  openssh-client \
  git \
  g++ \
  gcc \
  make \
  jq \
  yq \
  tar \
  unzip \
  wget \
  aria2 \
  binutils \
  brotli \
  coreutils \
  file \
  findutils \
  ftp \
  lz4 \
  mediainfo \
  net-tools \
  rsync \
  shellcheck \
  ssh \
  sudo \
  time \
  zip \
  zstd