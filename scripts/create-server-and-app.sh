#!/usr/bin/env bash

# Usage:
#       create-server-and-app.sh Create a server and a app in Treadmill.

# Timestamped log, e.g. log "cluster created".
#
# Input:
#   $1 Log string.
function log {
  echo -e "[`TZ=Asia/Shanghai date`] ${1}"
}

ROOT=$(dirname "${BASH_SOURCE}")/..

cd ${ROOT}
# Create a server.
./bin/treadmill --debug admin master server configure mock-server-1 -p /mock-parent
# Create a app to schedule.
./bin/treadmill --debug admin master app schedule mockappprefix.mock-app-1 -m ./scripts/app.yml --env dev --proid mock-proid-1
cd - > /dev/null
