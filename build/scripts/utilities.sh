#!/bin/bash
set -e
source /build/buildconfig
set -x

## Build tools
#$minimal_apt_get_install build-essential

## Language runtimes
$minimal_apt_get_install python ruby rbenv

## DBs
$minimal_apt_get_install mysql-client sqlite

## SCM tools
$minimal_apt_get_install git git-man subversion mercurial mercurial-git

## NodeJS and pre-preqs
curl -sL https://deb.nodesource.com/setup | bash -
$minimal_apt_get_install nodejs

## RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby=1.9.3 --auto-dotfiles

## Some useful build tools.
npm install -g node-gyp
npm install -g grunt-cli
npm install -g grunt-init
npm install -g bower
npm install -g less
gem install bundler

## Compass
$minimal_apt_get_build_dep ruby-compass
gem install compass
npm install -g grunt-contrib-compass