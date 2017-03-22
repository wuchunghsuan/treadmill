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

RSRC_ID=mock-user.mock-app
RSRC="${ROOT}/scripts/app.yml"

cd ${ROOT}
# Create a server.
#./bin/treadmill --debug admin master server configure localhost -p /mock-parent

# Create a app to schedule.
# Notice: wrong operation.
#./bin/treadmill --debug admin master app schedule mockappprefix.mock-app-1 -m ./scripts/app.yml --env dev --proid mock-proid-1
./bin/treadmill --debug --outfmt yaml admin invoke --cell gaocegege app create ${RSRC_ID} ${RSRC}
cd - > /dev/null
