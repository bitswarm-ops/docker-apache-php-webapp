#!/bin/bash
set -e
source /build/buildconfig
set -x

# Creating service account '${SERVICE_ACCT}' with uid of 1100 to allow other service accts to use 1000
useradd --create-home --home "${SERVICE_ACCT_HOME}" -u 1100 --shell /bin/bash $SERVICE_ACCT
usermod -G rvm -a $SERVICE_ACCT
passwd -d ${SERVICE_ACCT}

/build/my_init.d/10_service_acct.sh

