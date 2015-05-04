#!/bin/bash
set -e
source /build/buildconfig
set -x

mkdir -p $COMPOSER_HOME
curl -sS https://getcomposer.org/installer | php -- --install-dir=$COMPOSER_HOME
rm -f /usr/local/bin/composer
ln -s $COMPOSER_HOME/composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

exit