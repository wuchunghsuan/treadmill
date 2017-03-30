#!/usr/bin/env bash

# Usage:
#       invoke-app.sh Create a app in Treadmill.

# Timestamped log, e.g. log "cluster created".
#
# Input:
#   $1 Log string.
function log {
  echo -e "[`TZ=Asia/Shanghai date`] ${1}"
}

ROOT=$(dirname "${BASH_SOURCE}")/..

CELL="gaocegege"
RSRC_ID=mock-user.mock-app
RSRC="${ROOT}/manifests/app.yml"
OUTFMT="yaml"

cd ${ROOT}
# Create a app to schedule.
./bin/treadmill --debug --outfmt ${OUTFMT} admin invoke --cell ${CELL} instance create ${RSRC_ID} ${RSRC}
cd - > /dev/null
