#!/bin/bash
set -e -x

if [ ! -e /usr/local/src/drush ]; then
  mkdir -p /usr/local/src
  git clone -b "${DRUSH_VERSION}" https://github.com/drush-ops/drush.git /usr/local/src/drush
  cd /usr/local/src/drush
  ln -s /usr/local/src/drush/drush /usr/bin/drush
  /usr/local/bin/composer install \
      --no-interaction \
      --no-progress \
      --ignore-platform-reqs
else
  cd /usr/local/src/drush
  git fetch origin
  git checkout -f "${DRUSH_VERSION}"
  /usr/local/bin/composer update \
      --no-interaction \
      --no-progress \
      --ignore-platform-reqs
fi

drush --version