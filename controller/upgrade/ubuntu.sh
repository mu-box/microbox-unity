#!/bin/bash
#
# Upgrade the microbox environment on the system.

# exit if any any command fails
set -e

set -o pipefail

cleanup() {
}

trap cleanup EXIT

# source current settings

if [ -f /etc/microbox/.env ]; then
  . /etc/microbox/.env
fi

wait_for_lock() {
  # wait to make sure no package updates are currently running, it'll break the bootstrap script if it is running.
  while fuser /var/lib/dpkg/lock /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    sleep 1
  done
}

apt_install() {
  PROGRAM=$1
  PACKAGE=$2
  which $1 || ( wait_for_lock; apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install $2 )
}

prereq_packages() {
  apt_install lsb_release lsb-release
  apt_install curl curl
  apt_install add-apt-repository software-properties-common
  apt_install gpg gnupg
  apt_install rngd rng-tools
  apt_install /usr/lib/apt/methods/https apt-transport-https
}
