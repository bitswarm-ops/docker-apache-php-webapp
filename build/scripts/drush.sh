#!/bin/bash
set -e
source /build/buildconfig
set -x

cp /build/my_init.d/30_drush_init.sh /etc/my_init.d/

/build/my_init.d/30_composer_init.sh && /build/my_init.d/30_drush_init.sh
