#!/bin/bash

if [ "${SERVICE_ACCT_PASSWORD}" != 'CHANGE_ME' ]; then
  echo "### Changing service acct password for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT}:${SERVICE_ACCT_PASSWORD}" | chpasswd
else
  echo "### Leaving service acct ${SERVICE_ACCT} without a password"
fi

if [[ ! -e "${SERVICE_ACCT_HOME}/.ssh" ]]; then
  mkdir -p ${SERVICE_ACCT_HOME}/.ssh
  chmod 700 ${SERVICE_ACCT_HOME}/.ssh
fi

if [[ ! -e "/root/.ssh" ]]; then
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
fi

if [ "${SERVICE_ACCT_PRIVATE_KEY}" != 'CHANGE_ME' ]; then
  echo "### Setting private key for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT_PRIVATE_KEY}" > ${SERVICE_ACCT_HOME}/.ssh/id_rsa
  cp ${SERVICE_ACCT_HOME}/.ssh/id_rsa /root/.ssh/id_rsa
fi

AUTHORIZED_KEYS="${SERVICE_ACCT_HOME}/.ssh/authorized_keys"

if [ "${SERVICE_ACCT_PUBLIC_KEY}" != 'CHANGE_ME' ]; then
  echo "### Setting public key for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT_PUBLIC_KEY}" > ${SERVICE_ACCT_HOME}/.ssh/id_rsa.pub
  if [[ -e "$AUTHORIZED_KEYS" ]] && grep -q ${SERVICE_ACCT_PUBLIC_KEY} "$AUTHORIZED_KEYS"; then
	  echo "#### ${SERVICE_ACCT} public key has already been added to ${AUTHORIZED_KEYS}."
  else
    DIR=`dirname "$AUTHORIZED_KEYS"`
    echo "### Adding public key for ${SERVICE_ACCT} to ${AUTHORIZED_KEYS}" >> "$AUTHORIZED_KEYS"
    echo "#### Success: ${SERVICE_ACCT} public key has been added to ${AUTHORIZED_KEYS}"
  fi

  echo "### Adding public key for ${SERVICE_ACCT} to ${SERVICE_ACCT_HOME}/.ssh/authorized_keys"
  echo "${SERVICE_ACCT_PUBLIC_KEY}" >> ${SERVICE_ACCT_HOME}/.ssh/id_rsa.pub
  cp ${SERVICE_ACCT_HOME}/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
fi

chown -R "${SERVICE_ACCT}:${SERVICE_ACCT}" "${SERVICE_ACCT_HOME}/.ssh"

chmod 0644 ${SERVICE_ACCT_HOME}/.ssh/authorized_keys
chmod 0644 ${SERVICE_ACCT_HOME}/.ssh/*.pub
chmod 0644 /root/.ssh/authorized_keys
chmod 0644 /root/.ssh/*.pub


if [ $SERVICE_ACCT_SUDO_ENABLED -eq 1 ]; then
  echo "### sudo enabled for ${SERVICE_ACCT}"
  rm -f /etc/sudoers.d/$SERVICE_ACCT

  if [ $SERVICE_ACCT_SUDO_NO_PASSWD -eq 1 ]; then
    echo "### No password will be required for sudo operations for ${SERVICE_ACCT}"
    echo -n "%${DEVOPS_ACCT} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SERVICE_ACCT
  else
    echo "### Password will be required for sudo operations for ${SERVICE_ACCT}"
    echo -n "%${SERVICE_ACCT} ALL=(ALL:ALL) ALL" > /etc/sudoers.d/$SERVICE_ACCT
  fi
else
  echo "### Removing sudo access for ${SERVICE_ACCT}"
  rm -f /etc/sudoers.d/$SERVICE_ACCT
  sudo -l
fi

chown -R $SERVICE_ACCT:$SERVICE_ACCT $SERVICE_ACCT_HOME