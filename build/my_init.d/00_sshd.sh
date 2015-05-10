#!/bin/bash

if [ $SSHD_ENABLED -eq 1 ]; then
  echo "### sshd service enabled"
  if [ -e /etc/service/sshd/down ]; then
    rm -f /etc/service/sshd/down
  fi
else
  echo "### sshd service disabled"
  touch /etc/service/sshd/down
fi
