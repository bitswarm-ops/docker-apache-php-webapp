#!/bin/bash
set -e
source /build/buildconfig
set -x

$minimal_apt_get_install openssh-client openssh-server
cp -fRv /build/config/ssh/* /etc/ssh/

/build/my_init.d/15_sshd_init.sh