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

CELL="gaocegege"
SERVER_NAME="mock-server-1"
SERVER_PARENT="/mock-parent"
APP_NAME="mockappprefix.mock-app-1"
APP_MANIFEST="./manifests/low-level-app.yml"
APP_ENV="dev"
APP_PROID="mock-proid-1"

cd ${ROOT}
# Create a server.
./bin/treadmill --debug admin master --cell ${CELL} server configure ${SERVER_NAME} -p ${SERVER_PARENT}
# Create a app to schedule.
./bin/treadmill --debug admin master --cell ${CELL} app schedule ${APP_NAME} \
    -m ${APP_MANIFEST} --env ${APP_ENV} --proid ${APP_PROID}
cd - > /dev/null
