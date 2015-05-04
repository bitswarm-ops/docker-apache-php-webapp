#!/bin/bash
set -e -x

mkdir -p $COMPOSER_HOME/cache

if [[ "$GITHUB_OAUTH_TOKEN" != "CHANGE_ME" ]]; then
    /usr/local/bin/composer config --global github-oauth.github.com $GITHUB_OAUTH_TOKEN
fi

chmod -R o+rX $COMPOSER_HOME
chmod -R o+w $COMPOSER_HOME/cache