#!/bin/bash

if [ $SSHD_ENABLED -eq 1 ]; then
  echo "### sshd service enabled"
  rm -f /etc/service/sshd/down
else
  echo "### sshd service disabled"
  touch /etc/service/sshd/down
fi
