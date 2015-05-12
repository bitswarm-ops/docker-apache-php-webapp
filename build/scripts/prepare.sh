#!/bin/bash
set -e
source /build/buildconfig
set -x

## Temporarily disable dpkg fsync to make building faster.
echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

echo -n "${SERVICE_ACCT}" > /etc/container_environment/CURRENT_SERVICE_ACCT
echo -n "${SERVICE_ACCT_PASSWORD}" > /etc/container_environment/CURRENT_SERVICE_ACCT_PASSWORD
echo -n "${SERVICE_ACCT_HOME}" > /etc/container_environment/CURRENT_SERVICE_ACCT_HOME

## Enable Ubuntu Universe and Multiverse.
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list

apt-get update

if [ ! -e /opt ]; then
  mkdir /opt
fi