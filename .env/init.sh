#!/bin/sh
export TREADMILL_DNS_DOMAIN=treadmill-dev.ms.com
export TREADMILL_LDAP='ldap://localhost:10389'
export TREADMILL_LDAP_SEARCH_BASE='ou=treadmill,dc=ms,dc=com'
export TREADMILL_ENV=dev
export TREADMILL_PROID=treadmld
export TREADMILL_CELL=gaocegege
export TREADMILL_EXE_WHITELIST=/home/vagrant/treadmill/etc/linux.exe.config
export TREADMILL_WHITELIST=/home/vagrant/treadmill/etc/linux.exe.config
export TREADMILL_APPROOT=/tmp/treadmill.server.local
