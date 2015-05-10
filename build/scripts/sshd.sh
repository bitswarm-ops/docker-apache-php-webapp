#!/bin/bash
set -e
source /build/buildconfig
set -x

$minimal_apt_get_install openssh-client openssh-server
cp -fRv /build/config/ssh/* /etc/ssh/

cp -f /build/my_init.d/00_sshd.sh /etc/my_init.d/
mv /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/my_init.d/01_regen_ssh_host_keys.sh
