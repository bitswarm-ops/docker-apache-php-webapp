#!/bin/bash
set -x

SERVICE_ACCT_SSH_DIR="${SERVICE_ACCT_HOME}/.ssh"
AUTHORIZED_KEYS="${SERVICE_ACCT_HOME}/.ssh/authorized_keys"

CURRENT_SERVICE_ACCT=`cat /etc/container_environment/CURRENT_SERVICE_ACCT`
CURRENT_SERVICE_ACCT_PASSWORD=`cat /etc/container_environment/CURRENT_SERVICE_ACCT_PASSWORD`
CURRENT_SERVICE_ACCT_HOME=`cat /etc/container_environment/CURRENT_SERVICE_ACCT_HOME`

if [ "${SERVICE_ACCT}" != "${CURRENT_SERVICE_ACCT}" ]; then
  echo "### Changing service acct to ${SERVICE_ACCT} from ${CURRENT_SERVICE_ACCT}"
  usermod -l ${SERVICE_ACCT} -m -d ${SERVICE_ACCT_HOME} ${CURRENT_SERVICE_ACCT}
  echo -n "${SERVICE_ACCT}" > /etc/container_environment/CURRENT_SERVICE_ACCT
  echo -n "${SERVICE_ACCT_HOME}" > /etc/container_environment/CURRENT_SERVICE_ACCT_HOME
fi

if [ "${SERVICE_ACCT_PASSWORD}" == 'CHANGE_ME' ] || [ "${SERVICE_ACCT_PASSWORD}" == '' ]; then
  echo "### Removing service acct password for ${SERVICE_ACCT}"
  passwd -u -d ${SERVICE_ACCT}
elif [ "${SERVICE_ACCT_PASSWORD}" != "${CURRENT_SERVICE_ACCT_PASSWORD}" ]; then
  echo "### Changing service acct password for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT}:${SERVICE_ACCT_PASSWORD}" | chpasswd
  passwd -u ${SERVICE_ACCT}
  echo -n "${SERVICE_ACCT_PASSWORD}" > /etc/container_environment/CURRENT_SERVICE_ACCT_PASSWORD
else
  echo "### Leaving service acct ${SERVICE_ACCT} password unchanged"
fi

if [[ ! -e "${SERVICE_ACCT_SSH_DIR}" ]]; then
  mkdir -p "${SERVICE_ACCT_SSH_DIR}"
  chmod 700 "${SERVICE_ACCT_SSH_DIR}"
fi

if [[ ! -e "/root/.ssh" ]]; then
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
fi

if [ "${SERVICE_ACCT_PRIVATE_KEY}" != 'CHANGE_ME' ]; then
  echo "### Setting private key for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT_PRIVATE_KEY}" > ${SERVICE_ACCT_SSH_DIR}/id_rsa
  cp ${SERVICE_ACCT_SSH_DIR}/id_rsa /root/.ssh/id_rsa
fi

if [ "${SERVICE_ACCT_PUBLIC_KEY}" != 'CHANGE_ME' ]; then
  echo "### Setting public key for ${SERVICE_ACCT}"
  echo "${SERVICE_ACCT_PUBLIC_KEY}" > ${SERVICE_ACCT_SSH_DIR}/id_rsa.pub
  if [[ -e "$AUTHORIZED_KEYS" ]] && grep -q ${SERVICE_ACCT_PUBLIC_KEY} "$AUTHORIZED_KEYS"; then
	  echo "#### ${SERVICE_ACCT} public key has already been added to ${AUTHORIZED_KEYS}."
  else
    DIR=`dirname "$AUTHORIZED_KEYS"`
    echo "### Adding public key for ${SERVICE_ACCT} to ${AUTHORIZED_KEYS}" >> "$AUTHORIZED_KEYS"
    echo "#### Success: ${SERVICE_ACCT} public key has been added to ${AUTHORIZED_KEYS}"
  fi

  echo "### Adding public key for ${SERVICE_ACCT} to ${SERVICE_ACCT_SSH_DIR}/authorized_keys"
  echo "${SERVICE_ACCT_PUBLIC_KEY}" >> ${SERVICE_ACCT_SSH_DIR}/id_rsa.pub
  cp ${SERVICE_ACCT_SSH_DIR}/id_rsa.pub /root/.ssh/id_rsa.pub
fi

chown -R "${SERVICE_ACCT}:${SERVICE_ACCT}" "${SERVICE_ACCT_SSH_DIR}"

if [[ -e "${AUTHORIZED_KEYS}" ]]; then
  chmod 0644 "${AUTHORIZED_KEYS}"
else
  echo "### Disabling sshd due to empty ${AUTHORIZED_KEYS}"
  touch /etc/service/sshd/down
fi

if [[ -e "${SERVICE_ACCT_SSH_DIR}/id_rsa.pub" ]]; then
  chmod 0644 ${SERVICE_ACCT_SSH_DIR}/id_rsa.pub
fi

if [ -e /root/.ssh/id_rsa.pub ]; then
  chmod 0644 /root/.ssh/id_rsa.pub
fi

if [[ "${SERVICE_ACCT_PASSWORD}" == 'CHANGE_ME' ]] && [[ "${SERVICE_ACCT_PASSWORD}" == '' ]]; then
  echo "#### Disabling sudo due to empty SERVICE_ACCT_PASSWORD"
  export SERVICE_ACCT_SUDO_ENABLED=0
  echo -n '0' > /etc/container-environment/SERVICE_ACCT_SUDO_ENABLED
fi

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